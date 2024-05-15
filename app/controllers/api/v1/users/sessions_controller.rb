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
          raise Errors::LoginError, "Invalid email or password" unless user&.authenticate(params[:password])

          token, refreshToken = generate_and_save_tokens_for(user)
          render json: { user: UserSerializer.new(user).to_h, token: token, refreshToken: refreshToken }, status: :ok
        end

        def sign_out
          current_resource.tokens.destroy_all
          head :no_content
        end

        def refresh_token
          current_token = current_resource.tokens.find_by(refresh_token: params[:refresh_token])
          raise Errors::InvalidTokenError, "Invalid refresh token" unless current_token

          current_resource.tokens.destroy_all
          token, refreshToken = generate_and_save_tokens_for(current_resource)
          render json: { token: token, refreshToken: refreshToken }, status: :ok
        end

        private

        def sign_up_params
          params.permit(:first_name, :last_name, :email, :password)
        end

        def generate_and_save_tokens_for(user)
          token, refreshToken = TokenService.generate_tokens_for(user)
          refresh_token_expiration_time = Time.now + Settings.refresh_token_expiration_time
          Token.create!(user: user, refresh_token: refreshToken, expires_at: refresh_token_expiration_time)
          [token, refreshToken]
        end
      end
    end
  end
end

