# frozen_string_literal: true

module Api
  module V1
    module ErrorHandler
      extend ActiveSupport::Concern

      included do
        rescue_from StandardError, with: :handle_standard_error
        rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
        rescue_from Errors::LoginError, with: :login_error
        rescue_from Errors::InvalidTokenError, with: :invalid_token_error
      end
  
      private

      def invalid_token_error(exception)
        render json: { errors: exception.message }, status: :not_found
      end

      def login_error(exception)
        render json: { errors: exception.message }, status: :bad_request
      end

      def handle_standard_error(exception)
        render json: { errors: 'An error occurred. Please try again later.' }, status: :internal_server_error
      end
  
      def record_not_found(exception)
        message = 'The requested resource was not found.'
        render json: { errors: exception.message }, status: :not_found
      end
  
      def record_invalid(exception)
        errors = exception.record.errors
        attribute_errors = errors.to_hash.keys.each_with_object({}) do |key, hash|
          hash[key] = errors.full_messages_for(key).first
        end
  
        render json: { errors: attribute_errors }, status: :bad_request
      end
    end
  end
end