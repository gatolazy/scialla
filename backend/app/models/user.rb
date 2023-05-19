class User < ApplicationRecord

  # JWT values:
  JWT_ALGORITHM = "HS512".freeze
  JWT_KEY = Rails.application.secrets.secret_key_base



  has_secure_password validations: false



  after_initialize if: :new_record? do
    init_identifier
  end



  #############################################################################
  ### Public class methods                                                  ###
  #############################################################################

  # Login via username and password.
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



  # Login via JWT token.
  def self.token_login( token )
    # If the token is empty do nothing:
    return nil if token.to_s.blank?

    # Attempt to decode it:
    begin
      decoded = JWT
        .decode( token, JWT_KEY, true, algorithm: JWT_ALGORITHM )
        .first
        .deep_symbolize_keys

      # And return the relative user:
      return User.find_by identifier: decoded[ :i ]

    # On failure, we're done for:
    rescue
      return nil
    end
  end



  #############################################################################
  ### Public instance methods                                               ###
  #############################################################################

  # Generates a new JWT token with the given expiry (defaults to 24 hours).
  def generate_token( expiry: 24.hours.from_now  )
    return JWT
      .encode(
        { i: self.identifier, exp: expiry.to_i },
        JWT_KEY,
        JWT_ALGORITHM,
        { typ: "JWT" }
      )
  end



  # Initializes the identifier.
  # NOTE: by default this won't overwrite already existing identifiers.
  #       Forcing a re-init will invalidate all previously issued JWT tokens
  #       for the user.
  # NOTE: since this is a pretty destructive operation, this WILL NOT SAVE
  #       the model.
  def init_identifier( force: true )
    if self.identifier.to_s.blank? or force then
      # Ensure there are no duplicates (although it'd be quite rare):
      loop do
        self.identifier = SecureRandom.uuid.tr "-", ""
        break unless self.class.exists? identifier: identifier
      end
    end
    return self
  end



  # Forcedly resets a user identifier, saving the model.
  def reset_identifier
    self.init_identifier( force: true ).save
  end

end

