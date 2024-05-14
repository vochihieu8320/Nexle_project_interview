# frozen_string_literal: true

module Api
  module V1
    module Users
      class BaseController < ApplicationController
        include Api::V1::ErrorHandler
      end
    end
  end
end
