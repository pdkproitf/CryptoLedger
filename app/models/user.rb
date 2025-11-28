class User < ApplicationRecord
  has_many :accounts
  
  validates :email, presence: true, uniqueness: true
end
