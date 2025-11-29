# frozen_string_literal: true

class Currency < ApplicationRecord
  CACHE_EXPIRES_IN = 12.hours.freeze
  CACHE_KEYS = {
    available_currencies: 'available_currencies',
    currency_hash: 'currency_hash',
    fiat_currencies: 'fiat_currencies',
    crypto_currencies: 'crypto_currencies'
  }.freeze

  enum status: {
    active: 'active',
    inactive: 'inactive'
  }, _prefix: true

  enum currency_type: {
    fiat: 'fiat',
    crypto: 'crypto'
  }, _prefix: true

  validates :currency, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :precision, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true
  validates :currency_type, presence: true

  scope :active_currencies, -> { where(status: statuses[:active]) }

  after_commit :clear_cache_data

  class << self
    def clear_all_caches
      CACHE_KEYS.each { |key| Rails.cache.delete(key) }
    end

    def currency_hash
      Rails.cache.fetch(CACHE_KEYS[:currency_hash], expires_in: CACHE_EXPIRES_IN) do
        all.index_by(&:currency)
      end
    end

    def supported_currencies
      currency_hash.keys
    end

    def fiat_currencies
      Rails.cache.fetch(CACHE_KEYS[:fiat_currencies], expires_in: CACHE_EXPIRES_IN) do
        currency_hash.values.select(&:fiat?).map(&:currency).to_set
      end
    end

    def crypto_currencies
      Rails.cache.fetch(CACHE_KEYS[:crypto_currencies], expires_in: CACHE_EXPIRES_IN) do
        currency_hash.values.select(&:crypto?).map(&:currency).to_set
      end
    end
  end

  private

  def clear_cache_data
    self.class.clear_all_caches
  end
end
