class ApplicationController < ActionController::API

  #############################################################################
  ### Guards                                                                ###
  #############################################################################

  # Simple "all-for-one" error catcher.
  rescue_from "StandardError" do |e|
    # Error to send:
    error = { message: e.message, type: e.class }
    error[ :trace ] = e.backtrace unless Rails.env.production?

    render_error error
  end



  # User token checker.
  before_action :guard_ensure_token, except: [ :not_found ]



  #############################################################################
  ### Routes                                                                ###
  #############################################################################

  # Simple 404.
  def not_found
    head 404
  end



  #############################################################################
  ### Public instance methods                                               ###
  #############################################################################

  # Simple response data wrapper.
  def render_data( data, meta: {}, status: 200 )
    render \
      status: status,
      json: {
        data: data,
        meta: meta
      }
  end



  # Simple error data wrapper.
  def render_error( data, status: 500 )
    render \
      status: status,
      json: {
        error: data
      }
  end



  # User token checker.
  def guard_ensure_token
    # Decode the token:
    decoded = JwtAuth.decode_token \
      request
        .headers[ :Authorization ]
        .to_s
        .split
        .last
        .to_s
        .gsub /\s/, ""

    # It's 404 if the token isn't valid:
    head 403 and return if decoded.nil?

    # Set the user otherwise:
    @current_user = User.find_by identifier: decoded[ :i ]
  end

end
