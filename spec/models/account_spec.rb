require 'rails_helper'

RSpec.describe Account, type: :model do
  subject(:account) { build(:account) }

  it { expect(account.balance).not_to be_nil }
end
