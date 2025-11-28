class User < ApplicationRecord
  has_many :accounts
  has_many :transactions

  validates :email, presence: true, uniqueness: true
end
