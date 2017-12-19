class DeleteTables < ActiveRecord::Migration
  def change
    drop_table :transactions
    drop_table :residents
  end
end
