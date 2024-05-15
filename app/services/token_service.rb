# frozen_string_literal: true

class TokenService
  def self.decode(token)
    JWT.decode(token, nil, nil)
  end

  def self.generate_tokens_for(user)
    token = generate_token(user.id, Settings.token_expiration_time)
    refresh_token = generate_token(user.id, Settings.refresh_token_expiration_time)

    [token, refresh_token]
  end

  private

  def self.generate_token(user_id, expiration_time)
    expiration_time = (Time.now + expiration_time).to_i
    JWT.encode({ user_id: user_id, exp: expiration_time }, nil)
  end
end
