class ChangeRequiredFieldsInResidents < ActiveRecord::Migration
  def change
    change_column :residents, :first_name, :string, null: true
    change_column :residents, :last_name, :string, null: true
    change_column :residents, :phone, :string, null: true
  end
end
