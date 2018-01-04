class OrderDecorator < BaseDecorator

  delegate_all

  decorates_association :client

  def display_created_at
    source.created_at.strftime('%d.%m.%Y %H:%M:%S')
  end

end
