class User < ApplicationRecord

  has_secure_password validations: false



  after_initialize if: :new_record? do
    init_identifier
  end



  #############################################################################
  ### Public class methods                                                  ###
  #############################################################################

  # Login.
  def self.login( username:, pass: )
    # Attempt to find the user:
    user = User.find_by username: username

    # If the authentication is successfull, mark down the last login and return
    # the user:
    if user&.authenticate pass then
      user.update last_login_at: DateTime.now
      return user
    end

    # If we got here, the login has failed:
    return nil
  end



  #############################################################################
  ### Public instance methods                                               ###
  #############################################################################

  # Initializes the identifier.
  # NOTE: on an already existing user, this will invalidate all previously
  # issued tokens.
  def init_identifier
    loop do
      self.identifier = SecureRandom.uuid.tr "-", ""
      break unless self.class.exists? identifier: identifier
    end
    return self
  end

end

