class RoomChannel < ApplicationCable::Channel

  # Channel subscription.
  def subscribed
    # Check if there's a room for this user:
    room = ActivitiesManager.room_sorter[ connection.current_user.id ]

    # If none has been found, the user can't join:
    if room.nil? then
      connection.close

    # Otherwise we're no longer waiting for the user:
    else
      ActivitiesManager.waiting_list.remove connection.current_user.id
      stream_from "#{ActivitiesManager.channel :room}#{room}"
    end
  end



  # Channel unsubscription.
  def unsubscribed
    # TODO
  end



  # On message received
  def speak( data )
    # First off, get the room id:
    room = ActivitiesManager.room_sorter[ connection.current_user.id ]

    # If the picked player wrote something:
    if connection.current_user.id ==
         ActivitiesManager.games[ "#{room}_picked" ].to_i \
    then
      # Ignore everything unless it's its turn:
      if ActivitiesManager.games[ "#{room}_turn" ] == "picked" then
        # It's the players' turn now:
        ActivitiesManager.games[ "#{room}_turn" ] = "players"

        # If a player has guessed, note down its id:
        if "GUESSED" == data[ "message" ] then
          ActivitiesManager.games[ "#{room}_guessed" ] = \
            ActivitiesManager.games[ "#{room}_last" ]
        else
          ActionCable.server.broadcast \
            "#{ActivitiesManager.channel :room}#{room}",
            {
              game_over: false,
              winner: nil
            }
        end
      end

    # If the other players wrote something:
    else
      # Ignore everything unless it's their turn:
      if ActivitiesManager.games[ "#{room}_turn" ] == "players" then
        # First off, switch turn:
        ActivitiesManager.games[ "#{room}_turn" ] = "picked"

        # Mark down the last player:
        ActivitiesManager.games[ "#{room}_last" ] = connection.current_user.id

        # Broadcast the message to everyone:
        ActionCable.server.broadcast \
          "#{ActivitiesManager.channel :room}#{room}",
          {
            game_over: false,
            user: connection.current_user.display_name,
            attempt: "#{data[ "message" ]}"
          }
      end
    end
  end

end

