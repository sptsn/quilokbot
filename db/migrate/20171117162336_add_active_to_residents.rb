class AddActiveToResidents < ActiveRecord::Migration
  def change
    add_column :residents, :active, :boolean, default: true, null: false
  end
end
