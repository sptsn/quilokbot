class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  skip_before_action :verify_authenticity_token, :require_user
  # before_action :update_telegram_username, except: :start

  def message(data)
    case data['text']
    when /заявк/
      handle_order
    when /услуги/
      handle_services
    when /контакты/
      handle_contacts
    else
      respond_with :message, text: 'Для навигации используйте меню'
    end
  end

  def handle_contacts
    text = "☎️ Звоните: [+7(920)182-50-40](tel:+79201825040)
💻 Наш сайт: quilok.com
⭐️ Мы в социальных сетях:
[Вконтакте](https://vk.com/byquilok), [Facebook](https://fb.com/byquilok), [Instagram](https://instagram.com/byquilok)"

    respond_with :message, text: text, parse_mode: 'Markdown', disable_web_page_preview: true
  end

  def handle_services
    text = "<b>Мы можем:</b>\n" + services_list.except('➡️ Другой вопрос').map{|key, value| '•' + key[1..-1]}.join("\n")

    respond_with :message,
      text: text,
      parse_mode: 'HTML'
  end

  def start(data = nil, *)
    respond_with :message,
      text: "Для навигации используйте меню",
      reply_markup: default_keyboard
  end

  def handle_order
    respond_with :message,
      text: 'Выберите услугу',
      reply_markup: {
        inline_keyboard: services_list.map{ |key, value| [text: key, callback_data: value] }
      }
  end

  def callback_query(data)
    session['kind'] = data

    edit_message :text, text: "Выбрана услуга: #{services_list.key(data)}"

    if sender.present?
      complete_order
    else
      save_context :wait_for_contact
      respond_with :message,
        text: 'Напишите свое имя или нажмите кнопку ниже',
        reply_markup: {
          keyboard: [ [text: 'Отправить контакт', request_contact: true] ],
          resize_keyboard: true
        }
    end
  end

  context_handler :wait_for_contact do |*words|
    if payload['contact'].present?
      client = Client.new(
        first_name: payload['contact']['first_name'],
        last_name: payload['contact']['last_name'],
        phone: payload['contact']['phone_number'],
        telegram_id: payload['contact']['user_id'],
        telegram_username: from['username']
      )

      if client.save
        complete_order
      else
        respond_with :message,
          text: "Ошибка: #{client.errors.full_messages.first}. Заполни контактные данные и попробуй еще раз."
      end
    else
      session['name'] = words[0]
      save_context :wait_for_phone
      respond_with :message,
        text: 'Теперь пришлите свой номер',
        reply_markup: {
          remove_keyboard: true
        }
    end
  end

  context_handler :wait_for_phone do |*words|
    client = Client.new(
      first_name: session[:name],
      phone: words[0],
      telegram_id: from['id'],
      telegram_username: from['username']
    )
    if client.save
      complete_order
    else
      respond_with :message,
        text: "Ошибка: #{client.errors.full_messages.first}. Заполни контактные данные и попробуй еще раз."
    end
  end

  def complete_order
    Order.create(
      kind: session['kind'],
      client_id: sender.id
    )

    User.all.each do |u|
      Telegram.bot.send_message(
        text: "Новая заявка от клиента #{sender.decorate.display_name} (#{sender.phone}), тема: #{services_list.key(session['kind'])}",
        chat_id: u.telegram_id
      )
    end

    respond_with :message,
      text: 'Спасибо! Ваша заявка успешно отправлена. Менеджер обработает ее в ближайшее время 👌🏼',
      reply_markup: default_keyboard
  end

protected

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

  def default_keyboard
    {
      keyboard: [ [text: '📝 Наши услуги'], [text: '✏️ Оставить заявку'], [text: '📌 Наши контакты'] ],
      resize_keyboard: true
    }
  end

  def sender
    @sender ||= Client.find_by(telegram_id: from['id'])
  end

  # def update_telegram_username
  #   unless sender&.telegram_username
  #     sender.update_attribute(:telegram_username, from['username'])
  #   end
  # end
end
