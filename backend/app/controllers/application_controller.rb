class ApplicationController < ActionController::API

  #############################################################################
  ### Guards                                                                ###
  #############################################################################

  # Simple "all-for-one" error catcher.
  rescue_from "StandardError" do |e|
    error = { message: e.message, type: e.class }
    error[ :trace ] = e.backtrace unless Rails.env.production?
    render_error **error
  end



  # User token checker.
  before_action :token_login, except: [ :not_found ]



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
  def render_data( status: 200, **data )
    render \
      status: status,
      json: { data: data }
  end



  # Simple error data wrapper.
  def render_error( status: 500, **data )
    render \
      status: status,
      json: {
        error: data
      }
  end



  # User token checker.
  def token_login
    # Attempt a login via token:
    @current_user = User.token_login request.headers[ :Authorization ]

    # It's 404 if the token isn't valid:
    head 403 and return if @current_user.nil?
  end

end

