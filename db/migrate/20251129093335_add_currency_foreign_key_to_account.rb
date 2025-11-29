class AddCurrencyForeignKeyToAccount < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :accounts, :currencies, column: :currency, primary_key: :currency
  end
end
