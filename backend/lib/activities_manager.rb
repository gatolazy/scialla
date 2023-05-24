class ActivitiesManager

  #############################################################################
  ### Instance attributes                                                   ###
  #############################################################################

  attr_reader :teams



  #############################################################################
  ### Public class methods                                                  ###
  #############################################################################

  # Quick getter.
  def self.channel( type, env: false )
    return "#{"scialla_#{Rails.env}:" if env}#{type.to_s.underscore}_"
  end



  # Room sorter.
  def self.room_sorter
    return Kredis.hash "scialla_#{Rails.env}:sorter"
  end



  # Waiting list.
  def self.waiting_list
    return Kredis.list "scialla_#{Rails.env}:waiting", typed: :integer
  end



  # Room games.
  def self.games
    return Kredis.hash "scialla_#{Rails.env}:games"
  end



  #############################################################################
  ### Public instance methods                                               ###
  #############################################################################

  # Default constructor.
  # Makes up the teams and the room names.
  def initialize
    # NOTE: temporary pick the only activity available:
    activity = Activity.first

    # First off, clean this:
    @teams = Array.new

    # Ensure there are no leftovers:
    ActivitiesManager.room_sorter.remove
    ActivitiesManager.waiting_list.clear
    ActivitiesManager.games.clear

    # First off, get all players in the lobby:
    in_lobby = ActionCable
      .server
      .pubsub
      .send( :redis_connection )
      .pubsub \
        "channels",
        "#{ActivitiesManager.channel :lobby, env: true}*"

    # We gotta split players, so:
    while in_lobby.any? do
      # Number of players to pick, starting off as the max (ideal) amount:
      to_pick = activity.max_players

      # Potential leftovers:
      leftovers = in_lobby.size - to_pick

      # If that'd leave too few people to form a group on their own:
      if leftovers > 0 and leftovers < activity.min_players then
        # If we can create two smaller teams, do so:
        if in_lobby.size / activity.min_players > 1 then
          to_pick = in_lobby.size / 2
        # Otherwise, create one big team:
        else
          to_pick += leftovers
        end
      end

      # Now that we know how many to pick, do so:
      to_pick = in_lobby.sample to_pick

      # Make sure not to process them again:
      in_lobby -= to_pick

      # Map this only once:
      to_pick = to_pick.map do |u|
        u.gsub( /^#{ActivitiesManager.channel :lobby, env: true}/, "" ).to_i
      end

      # Save the data locally (so Redis won't be bothered each time):
      @teams << {
        users: to_pick,
        picked: nil,
        room: Room.create( activity: activity )
      }

      # Add data to the sorter:
      to_pick.each do |u|
        ActivitiesManager.room_sorter[ u ] = @teams.last[ :room ].id
        ActivitiesManager.waiting_list << u
      end
    end
  end



  # Actual game starter.
  def start
    # Send a message to each player in the lobby so they know where to
    # connect next:
    @teams.map do |t|
      t[ :users ].each do |u|
        self.broadcast \
          to: "#{ActivitiesManager.channel :lobby}#{u}",
          message: "RoomChannel"

        # Add the user to the match and increase its played matches:
        user = User.find u
        user.update total_activities: user.total_activities + 1
      end

      # Also initialize the matche's scores:
      t[ :room ].users += User.where( id: t[ :users ] )
    end

    # Let's wait at most 60 seconds:
    60.times do
      sleep 1 if ActivitiesManager.waiting_list.elements.any?
    end

    # Once we get here we can start with the players we have, so let's remove
    # useless data:
    ActivitiesManager.waiting_list.clear

    # NODE: shorthand, there is only one team:
    team = @teams.last
    return if ( team.nil? or team[ :users ].size < 2 )

    # Control variables:
    questions = Question.all.pluck :text
    last_picked_player = nil
    seconds_available = 60

    # No questions = stop:
    return if questions.empty?

    # As long as there are questions left:
    while questions.any? do
      # Grace time:
      sleep 5

      # Pick a random question, and do not repeat it:
      question = questions.sample
      questions.delete question

      # Eventual winner:
      winner = nil

      # Pick the player, ensuring we won't pick the last one:
      while team[ :picked ].nil? or 
            team[ :picked ][ :id ] == last_picked_player \
      do
        team[ :picked ] = { id: team[ :users ].sample }
      end
      last_picked_player = team[ :picked ][ :id ]

      picked_name = User.find( team[ :picked ][ :id ] ).display_name

      # Send everyone the data:
      self.broadcast \
        to: "#{ActivitiesManager.channel :room}#{team[ :room ].id}",
        message: {
          game_over: false,
          picked: { id: team[ :picked ], name: picked_name },
          question: question,
          seconds: seconds_available
        }

      # Note down the player who's picking, guessed is set at false and it's
      # the players' turn:
      ActivitiesManager.games[ "#{team[ :room ].id}_picked" ] = \
        team[ :picked ][ :id ]
      ActivitiesManager.games[ "#{team[ :room ].id}_guessed" ] = "0"
      ActivitiesManager.games[ "#{team[ :room ].id}_turn" ] = "players"

      # At this point... Polling!
      seconds_available.times do
        # If somebody has guessed:
        if 0 != ActivitiesManager.games[ "#{team[ :room ].id}_guessed" ].to_i \
        then
          # Increase the user's total score:
          winner = User.find \
            ActivitiesManager.games[ "#{team[ :room ].id}_guessed" ]
          winner.update total_score: winner.total_score + 1

          # And the match's score:
          score = team[ :room ].reload.scores.find_by user: winner
          score.update score: score.score + 1

          # Send a notificatoin:
          self.broadcast \
            to: "#{ActivitiesManager.channel :room}#{team[ :room ].id}",
            message: {
              game_over: false,
              winner: { id: winner.id, name: winner.display_name },
              scores: team[ :room ].reload.scores.map { |s| s.report }
            }

          # And we can move on to the next question:
          break
        end

        # If we got here, wait a second:
        sleep 1
      end

      # If we got here and nobody guessted:
      if winner.nil? then
        # Send a notificatoin:
        self.broadcast \
          to: "#{ActivitiesManager.channel :room}#{team[ :room ].id}",
          message: {
            game_over: false,
            time_over: true,
            scores: team[ :room ].reload.scores.map { |s| s.report }
          }
      end
    end

    # Once we get here, send a game recap:
    self.broadcast \
      to: "#{ActivitiesManager.channel :room}#{team[ :room ].id}",
      message: {
        game_over: true,
        scores: team[ :room ].reload.scores.map { |s| s.report }
      }
  end



  #############################################################################
  ### Private instance methods                                              ###
  #############################################################################

  private

  # Shorthand to send broadcasts via ActionCable.
  def broadcast( to:, message: )
    ActionCable.server.broadcast to, message
  end

end

