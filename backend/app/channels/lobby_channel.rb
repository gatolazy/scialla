class LobbyChannel < ApplicationCable::Channel

  # Everyone will subscribe here to signal they want to participate, and will
  # await to be sorted in a room.
  def subscribed
    stream_from "lobby_#{connection.current_user.id}"
  end



  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    # TODO: probably nothing, but in case I forgot something...
  end

end

