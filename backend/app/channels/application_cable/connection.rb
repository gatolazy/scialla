module ApplicationCable

  class Connection < ActionCable::Connection::Base

    identified_by :current_user

    def connect
      @current_user = User.token_login request.headers[ :Authorization ]
      raise "UNAUTHORIZED" if @current_user.nil?
    end

  end

end

