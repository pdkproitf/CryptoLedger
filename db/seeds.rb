# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

users = FactoryBot.create_list(:user, 10)

currencies = %w[BTC ETH USDC]
users.each do |user|
  currencies.each do |currency|
    account = FactoryBot.create(:account, user:, currency:)
    FactoryBot.create(:transaction, :deposit, user:, to_account: account, amount: 1000.0)
  end
end
