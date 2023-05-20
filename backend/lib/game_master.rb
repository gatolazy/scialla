class GameMaster

  #############################################################################
  ### Class attributes                                                      ###
  #############################################################################



  #############################################################################
  ### Instance attributes                                                   ###
  #############################################################################

  attr_reader :game_rules
  attr_reader :teams



  #############################################################################
  ### Public instance methods                                               ###
  #############################################################################

  # Default constructor.
  # Makes up the teams and the room names.
  def initialize
    # First off, clean this:
    @teams = Array.new

    # Shorthand:
    @game_rules = Rails.application.config.game_rules

    # Ensure there are no leftovers:
    self.redis_rooms_clear

    # First off, get all players in the lobby:
    in_lobby = ActionCable
      .server
      .pubsub
      .send( :redis_connection )
      .pubsub( "channels", "lobby_*" )

    # We gotta split players, so:
    while in_lobby.any? do
      # Number of players to pick, starting off as the max (ideal) amount:
      to_pick = @game_rules[ :max_players ]

      # Potential leftovers:
      leftovers = in_lobby.size - to_pick

      # If that'd leave too few people to form a group on their own:
      if leftovers > 0 and leftovers < @game_rules[ :min_players ] then
        # If we can create two smaller teams, do so:
        if in_lobby.size / @game_rules[ :min_players ] > 1 then
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
      to_pick = to_pick.map { |u| u.gsub( /^lobby_/ ).to_i }

      # Save the data locally (so Redis won't be bothered each time):
      @teams << {
        users: to_pick,
        room: "-#{to_pick.join "-"}-"
      }

      # Also add the data to redis for ActionCable:
      self.redis_rooms << @teams.last[ :room ]
    end
  end



  # Actual game starter.
  def start
    # TODO: create rooms via java rtcp application
    # TODO: send both Cable and webrtc room ids to clients currently in the
    #       lobby
    # TODO: handle dufferent rooms at the same time 
    # TODO: send questions to client
    # TODO: score? -> separate db table? so cable can write?
  end



  #############################################################################
  ### Private instance methods                                              ###
  #############################################################################

  private

  # Quick getter.
  def redis_rooms
    return Kredis.list @game_rules[ :kredis ]
  end



  # Quick cleaner.
  def redis_rooms_clear
    Kredis.list( @game_rules[ :kredis ] ).remove
  end


  # Shorthand to send broadcasts via ActionCable.
  def broadcast( to:, message: )
    ActionCable.server.broadcast to, message
  end

end

