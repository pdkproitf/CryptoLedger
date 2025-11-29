# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations, Metrics/BlockLength
RSpec.describe 'AccountsController', type: :request do
  RSpec.shared_examples 'returns success with accounts' do |expected_count|
    it "returns success with #{expected_count} accounts" do
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response['data']).to be_an(Array)
      expect(json_response['data'].size).to eq(expected_count)
    end
  end

  RSpec.shared_examples 'includes account attributes' do |expected_accounts|
    it 'includes all required account attributes' do
      expected_accounts = instance_exec(&expected_accounts)
      json_response = JSON.parse(response.body)

      json_response['data'].each do |account_json|
        expected_account = expected_accounts.find { |acc| acc.id == account_json['id'].to_i }
        expect(expected_account).to be_present

        attributes = account_json['attributes']
        expect(attributes['currency']).to eq(expected_account.currency)
        expect(attributes['user-id']).to eq(expected_account.user_id)
        expect(attributes).to have_key('balance')
      end
    end
  end

  RSpec.shared_examples 'returns failed with error' do |status, error|
    it "returns #{status} with error message" do
      expect(response).to have_http_status(status)
      json_response = JSON.parse(response.body)
      errors_detail = json_response['errors']['detail']

      error_text = errors_detail.is_a?(Array) ? errors_detail.join(' ') : errors_detail
      expect(error_text).to match(/#{error}/)
    end
  end

  describe 'GET /accounts' do
    let(:user) { create(:user) }
    let!(:btc_account) { create(:account, user:, currency: 'BTC') }
    let!(:eth_account) { create(:account, user:, currency: 'ETH') }
    let!(:usd_account) { create(:account, user:, currency: 'USD') }

    context 'when user is authenticated' do
      before { get '/api/v1/accounts', headers: { 'user-id' => user.id } }

      it_behaves_like 'returns success with accounts', 3
      it_behaves_like 'includes account attributes', -> { [btc_account, eth_account, usd_account] }
    end

    context 'when current user has no accounts' do
      let(:new_user) { create(:user, email: 'newuser@example.com') }

      before do
        get '/api/v1/accounts', headers: { 'user-id' => new_user.id }
      end

      it_behaves_like 'returns success with accounts', 0

      it 'returns empty array' do
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to eq([])
      end
    end

    context 'when user is not authenticated' do
      before { get '/api/v1/accounts' }

      it_behaves_like 'returns failed with error', :unauthorized, 'Unauthorized'
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, Metrics/BlockLength
