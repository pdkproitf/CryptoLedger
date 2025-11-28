# frozen_string_literal: true

# == Schema Information
# Table name: transactions
# id               :bigint           not null, primary key
# user_id          :bigint           not null
# transaction_type :string           not null
# from_account_id  :bigint
# to_account_id    :bigint
# amount           :decimal(20, 8)   not null
# exchange_rate    :decimal(20, 8)
# transaction_hash :string
# notes            :text
# created_at       :datetime         not null
# updated_at       :datetime         not null

class Transaction < ApplicationRecord
  include Transactions::Scopes

  belongs_to :user
  belongs_to :from_account, class_name: 'Account', optional: true
  belongs_to :to_account, class_name: 'Account', optional: true

  enum transaction_type: Transactions::Scopes::TRANSACTION_TYPES

  validates :transaction_type, presence: true, inclusion: { in: TRANSACTION_TYPES.values }
  validates_presence_of :user_id, :amount, :exchange_rate
end
