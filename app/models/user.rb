# frozen_string_literal: true

class User < ApplicationRecord
  SETTING_PASSWORD = Settings.user.password

  before_save :encrypt_password

  has_many :tokens, dependent: :destroy

  validates :email, :first_name, :last_name, :password, presence: true, on: :create
  validates :email, uniqueness: true
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, length: { in: SETTING_PASSWORD.min_length..SETTING_PASSWORD.max_length }

  def authenticate(password)
    BCrypt::Password.new(self.password) == password
  end

  def encrypt_password    
    self.password = BCrypt::Password.create(self.password)
  end
end
