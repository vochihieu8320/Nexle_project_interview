# frozen_string_literal: true

module Api
  module V1
    module Users
      class SessionsController < BaseController
        def create
          user = User.new(sign_up_params)
          user.save!
          render json: user, serializer: UserSerializer, status: :created
        end

        def sign_in
          user = User.find_by!(email: params[:email])

          if user.authenticate(params[:password])
            token = encode_token(user.id, 1.hour.from_now.to_i)
            refreshToken = encode_token(user.id, 30.days.from_now.to_i)
          else
            raise Errors::LoginError, "Invalid email or password"
          end
        end

        private

        def sign_up_params
          params.permit(:first_name, :last_name, :email, :password)
        end

        def encode_token(user_id, expiration_time)
          payload = { user_id: user_id, exp: expiration_time }
          JWT.encode(payload, nil, nil)
        end
      end
    end
  end
end
