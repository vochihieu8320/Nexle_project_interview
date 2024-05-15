# frozen_string_literal: true

class Token < ApplicationRecord
	belongs_to :user

	validates :refresh_token, :expires_at, presence: true
end
