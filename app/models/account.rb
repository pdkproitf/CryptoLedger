# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions_as_from, class_name: 'Transaction', foreign_key: 'from_account_id', dependent: :nullify
  has_many :transactions_as_to, class_name: 'Transaction', foreign_key: 'to_account_id', dependent: :nullify

  enum status: {
    active: 'active',
    closed: 'closed',
    locked: 'locked'
  }

  validates :currency, presence: true, uniqueness: { scope: :user_id }

  def balance
    @balance ||= calculate_balance
  end

  private

  def calculate_balance
    total_credits = transactions_as_to.sum(:amount)
    total_debits = transactions_as_from.sum(:amount)
    total_credits - total_debits
  end
end
