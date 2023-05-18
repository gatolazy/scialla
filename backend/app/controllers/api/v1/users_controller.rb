class Api::V1::UsersController < ApplicationController

  skip_before_action :guard_ensure_token, only: [ :login ]



  def foo
    render json: { datA: "ok" }
  end



  # Login route.
  def login
    # Attempt to login:
    @current_user = User.login \
      username: params[ :username ],
      pass: params[ :password ]

    raise "Invalid credentials" unless @current_user

    render_data( { token: JwtAuth.token_for( @current_user ) } )
  end

end

