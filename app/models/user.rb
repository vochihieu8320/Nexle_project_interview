# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, :first_name, :last_name, :password, presence: true, on: :create
  validates :email, uniqueness: true
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates :password, length: { in: 8..20 }

  before_save :encrypt_password

  def authenticate(password)
    BCrypt::Password.new(self.password) == password
  end

  def encrypt_password    
    self.password = BCrypt::Password.create(self.password)
  end
end