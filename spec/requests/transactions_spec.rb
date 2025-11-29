# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations, Metrics/BlockLength
RSpec.describe 'TransactionsController', type: :request do
  RSpec.shared_examples 'returns failed with error' do |status, error|
    it "returns #{status} with error message" do
      expect(response).to have_http_status(status)
      json_response = JSON.parse(response.body)
      errors_detail = json_response['errors']['detail']

      error_text = errors_detail.is_a?(Array) ? errors_detail.join(' ') : errors_detail
      expect(error_text).to match(/#{error}/)
    end
  end

  RSpec.shared_examples 'returns success with number of transactions' do |expected_count|
    it "returns success with #{expected_count} transactions" do
      json_response = JSON.parse(response.body)

      expect(json_response['data']).to be_an(Array)
      expect(json_response['data'].size).to eq(expected_count)
    end
  end

  RSpec.shared_examples 'returns success with transaction details' do |status, data|
    it "returns #{status} with data" do
      expect(response).to have_http_status(status)

      json_response = JSON.parse(response.body)['data']
      expect(json_response).to be_present

      expected_data = instance_exec(&data).symbolize_keys
      json_attributes = json_response.is_a?(Array) ? json_response.first['attributes'] : json_response['attributes']
      expect(json_attributes['transaction-type']).to eq(expected_data[:transaction_type])
      expect(json_attributes['from-account-id']).to eq(expected_data[:from_account_id])
      expect(json_attributes['to-account-id']).to eq(expected_data[:to_account_id])
      expect(json_attributes['amount'].to_f).to eq(expected_data[:amount])
      expect(json_attributes['exchange-rate'].to_f).to eq(expected_data[:exchange_rate])
    end
  end

  before do
    %w[BTC ETH USD].each { |currency| create(:currency, currency:) }
  end

  let(:user) { create(:user) }
  let!(:btc_account) { create(:account, user:, currency: 'BTC') }
  let!(:eth_account) { create(:account, user:, currency: 'ETH') }
  let!(:usd_account) { create(:account, user:, currency: 'USD') }
  let!(:other_user) { create(:user) }
  let(:other_account) { create(:account, user: other_user, currency: 'BTC') }

  describe 'GET /transactions' do
    let!(:deposit_transaction) { create(:transaction, :deposit, user:, to_account: usd_account) }
    let!(:trade_transaction) { create(:transaction, :trade, user:, from_account: btc_account, to_account: eth_account) }
    let!(:other_user_transaction) { create(:transaction, :deposit, user: other_user, to_account: btc_account) }

    context 'when user is authenticated' do
      before { get '/api/v1/transactions', headers: { 'user-id' => user.id } }

      it_behaves_like 'returns success with number of transactions', 2
      it_behaves_like 'returns success with transaction details', :ok, -> { user.transactions.first.attributes }

      it 'returns only transactions for the current user, not other users' do
        json_response = JSON.parse(response.body)
        expect(json_response['data'].size).to eq(2)

        user_ids = json_response['data'].map { |d| d['attributes']['user-id'] }
        expect(user_ids).to all(eq(user.id))
      end

      it 'returns empty array when current user has no transactions' do
        new_user = create(:user, email: 'newuser@example.com')
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(new_user)

        get '/api/v1/transactions', headers: { 'user-id' => new_user.id }

        json_response = JSON.parse(response.body)
        expect(json_response['data']).to eq([])
      end

      it 'filters transactions by transaction_type' do
        get '/api/v1/transactions', params: { type: 'deposit' }, headers: { 'user-id' => user.id }

        json_response = JSON.parse(response.body)
        expect(json_response['data'].size).to eq(1)

        transaction_types = json_response['data'].map { |d| d['attributes']['transaction-type'] }.uniq
        expect(transaction_types).to eq(['deposit'])
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/transactions'

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['errors']['detail']).to eq('Unauthorized')
      end
    end
  end

  describe 'POST /transactions' do
    let(:params) do
      {
        transaction: {
          transaction_type:,
          amount:,
          exchange_rate:,
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          notes: 'Test deposit'
        }
      }
    end
    let(:to_account) { usd_account }
    let(:from_account) { btc_account }
    let(:amount) { 1000.0 }
    let(:exchange_rate) { 1 }

    context 'when user is authenticated' do
      context 'when transaction is a deposit' do
        let(:transaction_type) { 'deposit' }

        context 'when invalid params' do
          let(:amount) { -100.0 }

          before { post '/api/v1/transactions', params:, headers: { 'user-id' => user.id } }

          it_behaves_like 'returns failed with error', :unprocessable_entity, 'Amount must be greater than 0'
        end

        context 'when valid params' do
          let(:amount) { 1000.0 }

          before { post '/api/v1/transactions', params:, headers: { 'user-id' => user.id } }

          it_behaves_like 'returns success with transaction details', :created, -> { params[:transaction] }
        end
      end

      context 'when transaction is a trade' do
        let(:transaction_type) { 'trade' }

        context 'when invalid params' do
          context 'when insufficient balance in from_account' do
            let(:amount) { from_account.balance + 1_000.0 }

            before { post '/api/v1/transactions', params:, headers: { 'user-id' => user.id } }

            it_behaves_like 'returns failed with error', :unprocessable_entity, 'Insufficient balance'
          end

          context 'when from_account does not belong to user' do
            let(:from_account) { create(:account, user: other_user, currency: 'BTC') }

            before { post '/api/v1/transactions', params:, headers: { 'user-id' => user.id } }

            it_behaves_like 'returns failed with error', :unprocessable_entity, 'Invalid from account'
          end
        end

        context 'when valid params' do
          let(:amount) { 0.5 }

          before do
            create(:transaction, :deposit, user:, to_account: from_account, amount: amount + 1000.0)
            post '/api/v1/transactions', params:, headers: { 'user-id' => user.id }
          end

          it_behaves_like 'returns success with transaction details', :created, -> { params[:transaction] }
        end
      end

      context 'when transaction is a withdrawal' do
        let(:transaction_type) { 'withdrawal' }

        context 'when invalid params' do
          context 'when insufficient balance in from_account' do
            let(:amount) { from_account.balance + 500.0 }

            before { post '/api/v1/transactions', params:, headers: { 'user-id' => user.id } }

            it_behaves_like 'returns failed with error', :unprocessable_entity, 'Insufficient balance'
          end

          context 'when from_account does not belong to user' do
            let(:from_account) { create(:account, user: other_user, currency: 'BTC') }

            before { post '/api/v1/transactions', params:, headers: { 'user-id' => user.id } }

            it_behaves_like 'returns failed with error', :unprocessable_entity, 'Invalid from account'
          end
        end

        context 'when valid params' do
          let(:amount) { 0.3 }

          before do
            create(:transaction, :deposit, user:, to_account: from_account, amount: amount + 500.0)
            post '/api/v1/transactions', params:, headers: { 'user-id' => user.id }
          end

          it_behaves_like 'returns success with transaction details', :created, -> { params[:transaction] }
        end
      end
    end

    context 'when user is not authenticated' do
      before { post '/api/v1/transactions', params: {} }

      it_behaves_like 'returns failed with error', :unauthorized, 'Unauthorized'
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, Metrics/BlockLength
