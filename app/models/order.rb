class Order < ActiveRecord::Base
  include AASM

  aasm column: :status do
    state :new, initial: true
    state :checked

    event :check do
      transitions from: :new, to: :checked
    end
  end

  belongs_to :client

  scope :ordered, -> { order(created_at: :desc) }

end
