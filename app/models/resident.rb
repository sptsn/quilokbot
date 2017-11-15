class Resident < ActiveRecord::Base

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :days, presence: true

end