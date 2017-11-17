class Resident < ActiveRecord::Base

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :days, presence: true
  validates :telegram_id, uniqueness: true

  scope :activated, -> { where(activated: true) }

end