class ResidentDecorator < BaseDecorator

  delegate_all

  decorates_association :sent_transactions
  decorates_association :received_transactions

  def display_name
    [source.first_name.titleize, source.last_name.titleize].join(' ')
  end

  def display_active
    source.active? ? '✓' : display_empty_space
  end

  def display_expire_at
    source.expire_at.try :strftime, '%d.%m.%Y'
  end

end
