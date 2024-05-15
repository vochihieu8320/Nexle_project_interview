# frozen_string_literal: true

FactoryBot.define do
  factory :token do
    refresh_token { Faker::Internet.uuid }
    expires_at { Time.zone.now }
    user
  end
end
