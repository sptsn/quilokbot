class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :telegram_id, :string
    add_column :users, :telegram_username, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
