class Resident < ActiveRecord::Base

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :days, presence: true
  validates :telegram_id, uniqueness: true, allow_nil: true, allow_blank: true

  scope :active, -> { where(active: true) }

  before_validation do
    self.telegram_id = nil if self.telegram_id.blank?
  end

end