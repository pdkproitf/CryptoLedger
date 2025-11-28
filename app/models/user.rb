# frozen_string_literal: true
class User < ApplicationRecord
  has_many :accounts
  has_many :transactions
  has_many :transactions_as_from, through: :accounts, source: :transactions_as_from
  has_many :transactions_as_to, through: :accounts, source: :transactions_as_to

  validates :email, presence: true, uniqueness: true
end
