# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations, Metrics/BlockLength
RSpec.describe 'TransactionsController', type: :request do
  let(:user) { create(:user) }
  let!(:btc_account) { create(:account, user: user, currency: 'BTC') }
  let!(:eth_account) { create(:account, user: user, currency: 'ETH') }
  let!(:usd_account) { create(:account, user: user, currency: 'USD') }

  describe 'GET /transactions' do
    let!(:deposit_transaction) { create(:transaction, :deposit, user: user, to_account: usd_account) }
  let!(:trade_transaction) { create(:transaction, :trade, user: user, from_account: btc_account, to_account: eth_account) }

    context 'when user is authenticated' do
      it 'returns all transactions for the current user' do
        get '/transactions', headers: { 'user-id' => user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to be_an(Array)
        expect(json_response['data'].size).to eq(2)

        transaction_types = json_response['data'].map { |t| t['transaction_type'] }
        expect(transaction_types).to match_array(%w[deposit trade])
      end

      it 'returns only transactions for the current user, not other users' do
        other_user = create(:user, email: 'other@example.com')
        other_account = create(:account, user: other_user, currency: 'BTC')
        create(:transaction, :deposit, user: other_user, to_account: other_account)

        get '/transactions', headers: { 'user-id' => user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(2)
        json_response['data'].each do |transaction|
          expect(transaction['user_id']).to eq(user.id)
        end
      end

      it 'returns empty array when current user has no transactions' do
        new_user = create(:user, email: 'newuser@example.com')
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(new_user)

        get '/transactions', headers: { 'user-id' => new_user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to eq([])
      end

      it 'includes transaction details in response' do
        get '/transactions', headers: { 'user-id' => user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        first_transaction = json_response['data'].first
        expect(first_transaction).to have_key('id')
        expect(first_transaction).to have_key('transaction_type')
        expect(first_transaction).to have_key('user_id')
        expect(first_transaction).to have_key('amount')
        expect(first_transaction).to have_key('exchange_rate')
        expect(first_transaction).to have_key('created_at')
        expect(first_transaction).to have_key('updated_at')
      end

      it 'filters transactions by transaction_type' do
        get '/transactions', params: { type: 'deposit' }, headers: { 'user-id' => user.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'].first['transaction_type']).to eq('deposit')
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized error' do
        get '/transactions'

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['errors']['detail']).to eq('Unauthorized')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, Metrics/BlockLength
