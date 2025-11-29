class AddStatusToAccount < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TYPE account_status AS ENUM ('active', 'locked', 'closed');
    SQL
    add_column :accounts, :status, :account_status, null: false, default: 'active'
  end

  def down
    remove_column :accounts, :status
    execute <<-SQL
      DROP TYPE account_status;
    SQL
  end
end
