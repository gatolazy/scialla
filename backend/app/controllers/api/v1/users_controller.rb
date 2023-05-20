class Api::V1::UsersController < ApplicationController

  skip_before_action :token_login, only: [ :login ]



  # Login route.
  def login
    @current_user = User.login \
      username: params[ :username ],
      pass: params[ :password ]

    raise "Invalid credentials" unless @current_user

    render_data \
      display_name: @current_user.display_name,
      department: @current_user.department,
      token: @current_user.generate_token
  end

end

