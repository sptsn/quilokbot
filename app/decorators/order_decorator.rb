class OrderDecorator < BaseDecorator

  delegate_all

  decorates_association :client

  def display_created_at
    source.created_at.strftime('%d.%m.%Y %H:%M:%S')
  end

  def display_kind
    services_list.key source.kind
  end

  def services_list
    {
      'Бот' => 'bot',
      'Сайт' => 'site',
      'Интернет-магазин' => 'shop',
      'Реклама' => 'adds',
      'Дизайн' => 'design'
    }
  end

end
