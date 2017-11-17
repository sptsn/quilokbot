class AddTelegramIdToResidents < ActiveRecord::Migration
  def change
    add_column :residents, :telegram_id, :string
  end
end
