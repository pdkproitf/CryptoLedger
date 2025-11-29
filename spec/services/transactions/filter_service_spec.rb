# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transactions::FilterService do
  let(:user) { create(:user) }
  let(:btc_account) { create(:account, user: user, currency: 'BTC') }
  let(:eth_account) { create(:account, user: user, currency: 'ETH') }
  let(:usd_account) { create(:account, user: user, currency: 'USD') }

  let!(:btc_deposit) { create(:transaction, user: user, transaction_type: 'deposit', to_account: btc_account, amount: 1.0) }
  let!(:eth_withdrawal) { create(:transaction, user: user, transaction_type: 'withdrawal', from_account: eth_account, amount: 0.5) }
  let!(:btc_eth_trade) { create(:transaction, user: user, transaction_type: 'trade', from_account: btc_account, to_account: eth_account, amount: 0.1) }
  let!(:usd_deposit) { create(:transaction, user: user, transaction_type: 'deposit', to_account: usd_account, amount: 1000) }

  describe '#call' do
    context 'without any filters' do
      it 'returns all transactions' do
        result = described_class.new(user.transactions, {}).call
        expect(result.count).to eq(4)
      end
    end

    context 'filtering by transaction type' do
      it 'filters by single type' do
        result = described_class.new(user.transactions, { type: 'deposit' }).call
        expect(result.count).to eq(2)
        expect(result).to include(btc_deposit, usd_deposit)
      end

      it 'filters by multiple types' do
        result = described_class.new(user.transactions, { type: 'deposit,withdrawal' }).call
        expect(result.count).to eq(3)
        expect(result).to include(btc_deposit, eth_withdrawal, usd_deposit)
      end

      it 'handles whitespace in filter' do
        result = described_class.new(user.transactions, { type: 'deposit, withdrawal' }).call
        expect(result.count).to eq(3)
      end
    end

    context 'filtering by currency' do
      it 'filters by single currency' do
        result = described_class.new(user.transactions, { currency: 'BTC' }).call
        expect(result.count).to eq(2)
        expect(result).to include(btc_deposit, btc_eth_trade)
      end

      it 'filters by multiple currencies' do
        result = described_class.new(user.transactions, { currency: 'BTC,ETH' }).call
        expect(result.count).to eq(3)
        expect(result).to include(btc_deposit, eth_withdrawal, btc_eth_trade)
      end

      it 'handles lowercase currency codes' do
        result = described_class.new(user.transactions, { currency: 'btc' }).call
        expect(result.count).to eq(2)
        expect(result).to include(btc_deposit, btc_eth_trade)
      end

      it 'includes transactions where currency is on either side' do
        result = described_class.new(user.transactions, { currency: 'ETH' }).call
        expect(result).to include(eth_withdrawal, btc_eth_trade)
      end
    end

    context 'filtering by both type and currency' do
      it 'applies both filters' do
        result = described_class.new(user.transactions, { type: 'deposit', currency: 'BTC' }).call
        expect(result.count).to eq(1)
        expect(result).to include(btc_deposit)
      end

      it 'returns empty when no matches' do
        result = described_class.new(user.transactions, { type: 'withdrawal', currency: 'USD' }).call
        expect(result.count).to eq(0)
      end
    end
  end
end
