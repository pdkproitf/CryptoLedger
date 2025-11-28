# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions_as_from, class_name: 'Transaction', foreign_key: 'from_account_id', dependent: :nullify
  has_many :transactions_as_to, class_name: 'Transaction', foreign_key: 'to_account_id', dependent: :nullify

  validates :currency, presence: true, uniqueness: { scope: :user_id }

  def balance
    incoming = transactions_as_to.sum(:amount)
    outgoing = transactions_as_from.sum(:amount)
    incoming - outgoing
  end
end
