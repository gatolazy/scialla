class JwtAuth

  # Default values:
  DEFAULT_ALGORITHM = "HS512".freeze
  DEFAULT_HEADERS = { typ: "JWT" }.freeze



  #############################################################################
  ### Public class methods                                                  ###
  #############################################################################

  # Generates a new token for the given user.
  def self.token_for( user, expiry: 24.hours.from_now  )
    return JWT.encode( \
      { i: user.identifier, exp: expiry.to_i },
      Rails.application.secrets.secret_key_base,
      DEFAULT_ALGORITHM,
      DEFAULT_HEADERS
    )
  end



  # Checks if the given token is valid.
  def self.decode_token( token )
    return nil if token.to_s.blank?

    begin
      return JWT.decode(
        token,
        Rails.application.secrets.secret_key_base,
        true,
        algorithm: DEFAULT_ALGORITHM
      ).first.deep_symbolize_keys
    rescue
    end

    # If we got here the token isn't valid and we should return false.
    return nil
  end

end

