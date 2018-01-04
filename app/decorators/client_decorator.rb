class ClientDecorator < BaseDecorator

  delegate_all

  def display_name
    [source.first_name&.titleize, source.last_name&.titleize].join(' ')
  end

  def display_name_with_telegram_username
    "#{source.first_name&.titleize} #{source.last_name&.titleize} (#{source.telegram_username})"
  end

  def display_active
    source.active? ? '✓' : '×'
  end

  def display_created_at
    source.created_at.strftime('%d.%m.%Y %H:%M:%S')
  end

end
