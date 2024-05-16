# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('valid@email.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
    it { should validate_length_of(:password).is_at_least(8).is_at_most(20) }    
  end

  describe 'associations' do
    it { should have_many(:tokens).dependent(:destroy) }
  end

  describe 'callbacks' do
    describe 'before_save' do
      let(:user) { User.new(first_name: 'John', last_name: 'Doe', email: 'john@example.com', password: 'password') }

      it 'should call encrypt_password' do
        expect(user).to receive(:encrypt_password)
        user.save
      end
    end
  end
end
