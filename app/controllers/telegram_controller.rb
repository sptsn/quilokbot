class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  skip_before_action :verify_authenticity_token, :require_user
  # before_action :update_telegram_username, except: :start
  before_action do
    if sender.present? && !sender.active?
      false
    end
  end

  def message(data)
    case data['text']
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
    Product.order(:id).each do |product|
      respond_with :message,
        text: "#{product.name}\n#{product.description}",
        reply_markup: {
          inline_keyboard: [ [text: 'Оставить заявку', callback_data: product.id] ]
        }
    end
  end

  def start(data = nil, *)
    respond_with :message,
      text: "Для навигации используйте меню",
      reply_markup: default_keyboard
  end

  def callback_query(data)
    session['product_id'] = data

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
      session['first_name'] = words[0]
      session['last_name'] = words[1]
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
      first_name: session[:first_name],
      last_name: session[:last_name],
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
      product_id: session['product_id'],
      client_id: sender.id
    )

    User.all.each do |u|
      Telegram.bot.send_message(
        text: "Новая заявка от клиента #{sender.decorate.display_name} (#{sender.phone}), тема: #{Product.find(session[:product_id]).name}",
        chat_id: u.telegram_id
      )
    end

    respond_with :message,
      text: 'Спасибо! Ваша заявка успешно отправлена. Менеджер обработает ее в ближайшее время 👌🏼',
      reply_markup: default_keyboard
  end

protected

  def default_keyboard
    {
      keyboard: [ {text: '📝 Наши услуги'}, {text: '📌 Наши контакты'} ],
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
