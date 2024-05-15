# frozen_string_literal: true

module Api
  module V1
    module Users
      class BaseController < ApplicationController
        include Api::V1::ErrorHandler

        before_action :authenticate_resource!

        private

        def request_token
          pattern = /^Bearer /
          header = request.headers['Authorization']
          token = header.gsub(pattern, '') if header&.match(pattern)
          token || params[:refresh_token]
        end

        def decode_token
          return {} if request_token.blank?

          TokenService.decode(request_token).first
        end

        def authenticate_resource!
          current_resource
        end

        def current_resource
          @current_resource ||= User.find(decode_token['user_id'])
        end
      end
    end
  end
end
