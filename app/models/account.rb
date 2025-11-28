class Account < ApplicationRecord
  belongs_to :user

  validates :currency, presence: true

  # TODO: Implement this method
  # This method returns the current balance of an account currency
  def balance
    raise NotImplementedError
  end
end
