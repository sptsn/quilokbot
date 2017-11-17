class AddTelegramUsernameToResident < ActiveRecord::Migration
  def change
    add_column :residents, :telegram_username, :string
  end
end
