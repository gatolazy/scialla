class RoomChannel < ApplicationCable::Channel

  # Channel subscription.
  def subscribed
    # Check if there's a room for this user::
    room = Kredis
      .list( Rails.application.config.game_rules[ :kredis ] )
      .elements
      .find { |e| e.match "-#{connection.current_user.id}-" }

    # If none has been found, the user can't join:
    connection.close if room.nil?

    stream_from "room_#{room}"
  end



  # Channel unsubscription.
  def unsubscribed
    # TODO
  end



  # On message received
  def speak( data )
    # TODO: data[ "message" ] must be a json.
    ActionCable.server.broadcast \
      "room_channel",
      "#{connection.current_user.username}: #{data[ "message" ]}"
  end

end

