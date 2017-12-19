class UserDecorator < BaseDecorator

  delegate_all

  def display_created_at
    source.created_at.strftime('%d.%m.%Y %H:%M:%S')
  end

  def display_name
    [source.first_name&.titleize, source.last_name&.titleize].join(' ')
  end

end
