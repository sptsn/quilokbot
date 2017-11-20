class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :receiver_id, null: false
      t.integer :sender_id, null: false
      t.integer :days, null: false
      t.timestamps
    end
  end
end
