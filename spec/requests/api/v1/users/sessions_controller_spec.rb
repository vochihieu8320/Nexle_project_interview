# frozen_string_literal: true
include FactoryBot::Syntax::Methods

require 'rails_helper'

RSpec.describe Api::V1::Users::SessionsController, type: :controller do
  describe 'POST #sign_up' do
    let(:invalid_attributes) { { email: 'newuser@example.com', password: 'password' } }
    let(:valid_attributes) { 
      { 
        email: 'newuser@example.com', 
        password: 'password1234',
        first_name: "first_name",
        last_name: "last_name" 
      } 
    }

    context 'when invalid attributes' do
      it { expect { post :create, params: invalid_attributes }.not_to change(User, :count) }
      it do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end
    end
    
    context 'when unhandled error occurs' do
      before do
        allow_any_instance_of(User).to receive(:save!).and_raise(StandardError)
        post :create, params: valid_attributes
      end

      it { expect(response).to have_http_status(:internal_server_error) } 
      it { expect(JSON.parse(response.body)).to eq({ "errors"=>"An error occurred. Please try again later." }) }
    end

    context 'when valid attributes' do
      it { expect { post :create, params: valid_attributes }.to change(User, :count).by(1) }
      it do 
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'POST #sign_in' do
    let!(:user) { create(:user, email: "newuser@example.com", password: "password1234") }
    
    let(:valid_params) { 
      { 
        email: 'newuser@example.com', 
        password: 'password1234',
      }
    }

    let(:invalid_params) { { email: 'newuser@example.com', password: 'password' } }

    context 'when invalid params' do
      before do
        post :sign_in, params: invalid_params
      end

      it { expect(response).to have_http_status(:bad_request) }
      
      it 'returns an error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Invalid email or password')
      end
    end

    context 'when unhandled error occurs' do
      before do
        allow_any_instance_of(User).to receive(:authenticate).and_raise(StandardError)
        post :sign_in, params: valid_params
      end
    
      it { expect(response).to have_http_status(:internal_server_error) }
      it { expect(JSON.parse(response.body)).to eq({ "errors"=>"An error occurred. Please try again later." }) }
    end

    context 'when valid params' do
      before do
        post :sign_in, params: valid_params
      end

      it { expect(response).to have_http_status(:ok) }
      
      it 'returns the user details and tokens' do
        json_response = JSON.parse(response.body)

        expect(json_response['user']).to eq(UserSerializer.new(user).to_h.transform_keys(&:to_s))
        expect(json_response['token']).not_to be_nil
        expect(json_response['refreshToken']).not_to be_nil
      end
    end
  end

  describe 'DELETE #sign_out' do
    let!(:user) { create(:user) }
    let!(:token) { create(:token, user: user, refresh_token: JWT.encode({user_id: user.id}, nil)) }

    before do
      request.headers['Authorization'] = "Bearer #{token.refresh_token}"
      delete :sign_out
    end

    it { expect(response).to have_http_status(:no_content) }
    it { expect(user.tokens.count).to eq(0) }

    context 'when unhandled error occurs' do
      before do
        allow_any_instance_of(User).to receive_message_chain(:tokens, :destroy_all).and_raise(StandardError)
        delete :sign_out
      end
    
      it { expect(response).to have_http_status(:internal_server_error) }
      it { expect(JSON.parse(response.body)).to eq({ "errors"=>"An error occurred. Please try again later." }) }
    end
  end

  describe 'POST #refresh_token' do
    let!(:user) { create(:user) }
    let!(:token) { create(:token, user: user, refresh_token: JWT.encode({user_id: user.id}, nil)) }
    let(:refresh_token) { token.refresh_token }

    before do
      request.headers['Authorization'] = "Bearer #{token.refresh_token}"
      post :refresh_token, params: { refresh_token: refresh_token }
    end

    context 'when invalid token' do
      let(:refresh_token) { nil }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(JSON.parse(response.body)).to eq({ "errors"=>"Invalid refresh token" }) }
    end

    context 'when an error occurs' do
      before do
        allow_any_instance_of(User).to receive(:tokens).and_raise(StandardError)
        post :refresh_token, params: { refresh_token: refresh_token }
      end
    
      it { expect(response).to have_http_status(:internal_server_error) }
      it { expect(JSON.parse(response.body)["errors"]).to eq("An error occurred. Please try again later.") }
    end
    context 'when valid token' do
      it { expect(response).to have_http_status(:ok) }

      it 'generates new tokens' do
        json_response = JSON.parse(response.body)

        expect(json_response['token']).not_to be_nil
        expect(json_response['refreshToken']).not_to be_nil
      end

      let!(:tokens) { create_list(:token, 3, user: user) }

      it 'deletes old tokens and only new token generate available' do
        post :refresh_token, params: { refresh_token: tokens.first.refresh_token }
        expect(user.tokens.reload.count).to eq(1)
      end      
    end
  end
end
