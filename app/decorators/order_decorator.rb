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
      '👾 Создать бота' => 'bot',
      '💻 Создать сайт-визитку' => 'landing',
      '🖥 Создать интернет-магазин' => 'shop',
      '📈 Настроить Яндекс.Директ' => 'direct',
      '💡 SMM-маркетинг' => 'smm',
      '📸 Создать виртуальный тур' => 'tour',
      '➡️ Другой вопрос' => 'other'
    }
  end

end
