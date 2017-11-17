class Resident < ActiveRecord::Base

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :days, presence: true
  validates :telegram_id, uniqueness: true, allow_blank: true, allow_nil: true

  scope :active, -> { where(active: true) }

end