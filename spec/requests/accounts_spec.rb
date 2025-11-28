# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations, Metrics/BlockLength
RSpec.describe 'AccountsController', type: :request do
  describe 'GET /accounts' do
    let(:user) { create(:user) }
    let!(:btc_account) { create(:account, user: user, currency: 'BTC') }
    let!(:eth_account) { create(:account, user: user, currency: 'ETH') }
    let!(:usd_account) { create(:account, user: user, currency: 'USD') }

    context 'when user is authenticated' do
      it 'returns all accounts for the current user' do
        get '/accounts', headers: { 'user-id' => user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to be_an(Array)
        expect(json_response['data'].size).to eq(3)

        currencies = json_response['data'].map { |account| account['currency'] }
        expect(currencies).to match_array(['BTC', 'ETH', 'USD'])
      end

      it 'returns only accounts for the current user, not other users' do
        other_user = create(:user, email: 'other@example.com')
        create(:account, user: other_user, currency: 'BTC')
        create(:account, user: other_user, currency: 'ETH')

        get '/accounts', headers: { 'user-id' => user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(3)
        json_response['data'].each do |account|
          expect(account['user_id']).to eq(user.id)
        end
      end

      it 'returns empty array when current user has no accounts' do
        new_user = create(:user, email: 'newuser@example.com')
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(new_user)

        get '/accounts', headers: { 'user-id' => new_user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to eq([])
      end

      it 'includes account details in response' do
        get '/accounts', headers: { 'user-id' => user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        first_account = json_response['data'].first
        expect(first_account).to have_key('id')
        expect(first_account).to have_key('currency')
        expect(first_account).to have_key('user_id')
        expect(first_account).to have_key('created_at')
        expect(first_account).to have_key('updated_at')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized error' do
        get '/accounts'

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['errors']['detail']).to eq('Unauthorized')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, Metrics/BlockLength
