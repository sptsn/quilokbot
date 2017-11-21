class TransactionDecorator < BaseDecorator

  delegate_all

  decorates_association :sender
  decorates_association :receiver

  def display_created_at
    source.created_at.strftime('%d.%m.%Y %H:%M:%S')
  end

end
