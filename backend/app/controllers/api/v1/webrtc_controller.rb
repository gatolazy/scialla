class Api::V1::WebrtcController < ApplicationController

  # Check auth.
  def auth
    # TODO: check @current_users vs kredis rooms.
    head 200
  end

end

