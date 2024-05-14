# frozen_string_literal: true

module Api
  module V1
    module ErrorHandler
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
        rescue_from Errors::LoginError, with: :login_error
      end
  
      private

      def login_error(exception)
        render json: {
          errors: {
            resource: nil,
            code: 'LOGIN_ERROR',
            attribute: nil,
            message: exception.message
          }
        }, status: :not_found
      end
  
      def record_not_found(exception)
        render json: {
          errors: {
            resource: exception.model,
            code: 'RESOURCE_NOT_FOUND',
            attribute: exception.primary_key,
            message: 'The requested resource was not found.'
          }
        }, status: :not_found
      end
  
      def record_invalid(exception)
        errors = exception.record.errors
        attribute_errors = errors.to_hash.keys.each_with_object({}) do |key, hash|
          hash[key] = errors.full_messages_for(key).first
        end
  
        render json: { errors: attribute_errors }, status: :unprocessable_entity
      end
    end
  end
end
