class CreateCurrencies < ActiveRecord::Migration[7.0]
  def change
    create_table :currencies, id: false, primary_key: :currency do |t|
      t.string :currency, null: false, primary_key: true
      t.string :name, null: false
      t.integer :precision, null: false
      t.string :status, null: false
      t.string :currency_type, null: false

      t.timestamps
    end

    add_index :currencies, :currency, unique: true
  end
end
