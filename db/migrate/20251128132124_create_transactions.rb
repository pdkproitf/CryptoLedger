class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :transaction_type, null: false
      t.references :from_account, foreign_key: { to_table: :accounts }
      t.references :to_account, foreign_key: { to_table: :accounts }
      t.decimal :amount, null: false, precision: 20, scale: 8
      t.decimal :exchange_rate, precision: 20, scale: 8
      t.string :transaction_hash
      t.text :notes

      t.timestamps
    end
  end
end
