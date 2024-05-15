# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < BaseController
        skip_before_action :authenticate_resource!, only: %i[create sign_in]

        def create
          user = User.new(sign_up_params)
          user.save!
          render json: user, serializer: UserSerializer, status: :created
        end

        def sign_in
          user = User.find_by(email: params[:email])
          validate_password_length(params[:password])
          raise Errors::LoginError, "Invalid email or password" unless user&.authenticate(params[:password])

          token, refreshToken = generate_and_save_tokens_for(user)
          render json: { user: UserSerializer.new(user).to_h, token: token, refreshToken: refreshToken }, status: :ok
        end

        def sign_up_params
          params.permit(:first_name, :last_name, :email, :password)
        end

        def generate_and_save_tokens_for(user)
          token, refreshToken = TokenService.generate_tokens_for(user)
          refresh_token_expiration_time = Time.now + Settings.refresh_token_expiration_time
          Token.create!(user: user, refresh_token: refreshToken, expires_at: refresh_token_expiration_time)
          [token, refreshToken]
        end

        def validate_password_length(password)
          unless password.length.between?(8, 20)
            raise Errors::LoginError, "Password must be between 8 and 20 characters long"
          end
        end
      end
    end
  end
end

