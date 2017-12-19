class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :telegram_id
      t.string :telegram_username
      t.timestamps
    end
  end
end
