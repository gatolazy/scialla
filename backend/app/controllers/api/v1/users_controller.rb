class Api::V1::UsersController < ApplicationController

  skip_before_action :token_login, only: [ :login ]



  # Simple auth test.
  def foo
    render json: { data: @current_user.username }
  end



  # Login route.
  def login
    # Attempt to login:
    @current_user = User.login \
      username: params[ :username ],
      pass: params[ :password ]

    raise "Invalid credentials" unless @current_user

    render_data( { token: @current_user.generate_token } )
  end

end

