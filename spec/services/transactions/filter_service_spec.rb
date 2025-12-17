
# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations, Metrics/BlockLength
RSpec.describe Transactions::FilterService do
  let(:user) { create(:user) }

  let!(:btc_currency) { create(:currency, currency: 'BTC') }
  let!(:eth_currency) { create(:currency, currency: 'ETH') }
  let!(:usd_currency) { create(:currency, :fiat) }

  let!(:btc_account) { create(:account, user: user, currency: 'BTC') }
  let!(:eth_account) { create(:account, user: user, currency: 'ETH') }
  let!(:usd_account) { create(:account, user: user, currency: 'USD') }

  let!(:btc_deposit) do
    create(:transaction,
      user: user,
      transaction_type: 'deposit',
      from_account: nil,
      to_account: btc_account,
      amount: 1.0
    )
  end

  let!(:eth_withdrawal) do
    create(:transaction,
      user: user,
      transaction_type: 'withdrawal',
      from_account: eth_account,
      to_account: nil,
      amount: 0.5
    )
  end

  let!(:btc_eth_trade) do
    create(:transaction,
      user: user,
      transaction_type: 'trade',
      from_account: btc_account,
      to_account: eth_account,
      amount: 0.1
    )
  end

  let!(:usd_deposit) do
    create(:transaction,
      user: user,
      transaction_type: 'deposit',
      from_account: nil,
      to_account: usd_account,
      amount: 1000
    )
  end

  describe '#call' do
    context 'without any filters' do
      it 'returns all transactions' do
        result = described_class.new(user, {}).call
        expect(result.success?).to be true
        expect(result.data.count).to eq(4)
      end
    end

    context 'filtering by transaction type' do
      it 'filters by single type' do
        result = described_class.new(user, { type: 'deposit' }).call
        expect(result.success?).to be true
        expect(result.data.count).to eq(2)
        expect(result.data).to include(btc_deposit, usd_deposit)
      end

      it 'filters by multiple types' do
        result = described_class.new(user, { type: 'deposit,withdrawal' }).call
        expect(result.success?).to be true
        expect(result.data.count).to eq(3)
        expect(result.data).to include(btc_deposit, eth_withdrawal, usd_deposit)
      end

      it 'handles whitespace in filter' do
        result = described_class.new(user, { type: 'deposit, withdrawal' }).call
        expect(result.success?).to be true
        expect(result.data.count).to eq(3)
      end
    end

    context 'filtering by currency' do
      it 'filters by single currency (trade only)' do
        result = described_class.new(user, { currency: 'BTC' }).call
        expect(result.success?).to be true
        expect(result.data).to include(btc_eth_trade)
      end

      it 'filters by multiple currencies (trades only)' do
        result = described_class.new(user, { currency: 'BTC,ETH' }).call
        expect(result.success?).to be true
        expect(result.data).to include(btc_eth_trade)
      end

      it 'handles lowercase currency codes' do
        result = described_class.new(user, { currency: 'btc' }).call
        expect(result.success?).to be true
        expect(result.data).to include(btc_eth_trade)
      end
    end

    context 'filtering by both type and currency' do
      it 'applies both filters' do
        result = described_class.new(user, { type: 'trade', currency: 'BTC' }).call
        expect(result.success?).to be true
        expect(result.data.count).to eq(1)
        expect(result.data).to include(btc_eth_trade)
      end

      it 'returns empty when no matches' do
        result = described_class.new(user, { type: 'withdrawal', currency: 'USD' }).call
        expect(result.success?).to be true
        expect(result.data.count).to eq(0)
      end
    end

    context 'error handling' do
      it 'returns error result when exception occurs' do
        allow(user).to receive(:transactions).and_raise(ActiveRecord::StatementInvalid.new('Database error'))

        result = described_class.new(user, {}).call
        expect(result.success?).to be false
        expect(result.error?).to be true
        expect(result.errors).to include('Database error')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, Metrics/BlockLength
