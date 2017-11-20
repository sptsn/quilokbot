class Transaction < ActiveRecord::Base

  belongs_to :sender, class_name: 'Resident', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'Resident', foreign_key: :receiver_id

  validates :sender, presence: true
  validates :receiver, presence: true
  validates :days, presence: true

end