class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  skip_before_action :verify_authenticity_token, :require_user
  # before_action :update_telegram_username, except: :start

  before_action do
    case payload['text']
    when 'Оставить заявку'
      handle_order
    when 'Услуги'
      handle_services
    end
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

  def handle_services
    respond_with :message,
      text: services_list.map{|key, value| key}.join("\n"),
      reply_markup: {
        keyboard: [ [text: 'Оставить заявку'], [text: 'Услуги'] ],
        resize_keyboard: true,
        one_time_keyboard: true
      }
  end

  def update_telegram_username
    unless sender&.telegram_username
      sender.update_attribute(:telegram_username, from['username'])
    end
  end

  def start(data = nil, *)
    respond_with :message,
      text: "Привет, это телеграм-бот студии Quilok. Чтобы оставить заявку, нажми кнопку ниже.",
      reply_markup: {
        keyboard: [ [text: 'Оставить заявку'], [text: 'Услуги'] ],
        resize_keyboard: true,
        one_time_keyboard: true
      }
  end

  def handle_order
    if sender.present?
      respond_services
    else
      save_context :wait_for_contact
      respond_with :message,
        text: 'Отлично, пришли свой контакт чтоб я мог тебя запомнить.',
        reply_markup: {
          keyboard: [ [text: 'Отправить контакт', request_contact: true] ],
          resize_keyboard: true
        }
    end
  end

  context_handler :wait_for_contact do |*words|
    unless payload['contact'].present?
      save_context :wait_for_contact
      respond_with :message, text: 'Просто пришли контакт'
      return
    end

    client = Client.new(
      first_name: payload['contact']['first_name'],
      last_name: payload['contact']['last_name'],
      phone: payload['contact']['phone_number'],
      telegram_id: payload['contact']['user_id'],
      telegram_username: from['username']
    )

    if client.save
      respond_services
    else
      save_context :wait_for_contact
      respond_with :message,
        text: "Ошибка: #{client.errors.full_messages.first}. Заполни контактные данные и попробуй еще раз."
    end
  end

  def respond_services
    respond_with :message,
      text: 'Выбери услугу',
      reply_markup: {
        remove_keyboard: true,
        inline_keyboard: services_list.map{ |key, value| [text: key, callback_data: value] }
      }
  end

  def callback_query(data)
    Order.create(
      kind: data,
      client_id: sender.id
    )

    User.all.each do |u|
      Telegram.bot.send_message text: "Новая заявка от клиента #{sender.decorate.display_name} (#{sender.phone}), тема: #{services_list.key(data)}", chat_id: u.telegram_id
    end

    edit_message :text, text: "Выбрана услуга: #{services_list.key(data)}"

    respond_with :message,
      text: 'Заявка отправлена, скоро мы свяжемся с вами',
      reply_markup: {
        keyboard: [ [text: 'Оставить заявку'], [text: 'Услуги'] ],
        resize_keyboard: true
      }
  end


  protected

  def sender
    @sender ||= Client.find_by(telegram_id: from['id'])
  end

end
