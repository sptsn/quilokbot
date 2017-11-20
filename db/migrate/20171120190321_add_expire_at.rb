class AddExpireAt < ActiveRecord::Migration
  def change
    add_column :residents, :expire_at, :date
    remove_column :residents, :days
  end
end
