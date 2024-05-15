# frozen_string_literal: true

module Errors
  class BaseError < StandardError
    def initialize(message)
      super(message)
    end
  end
end
