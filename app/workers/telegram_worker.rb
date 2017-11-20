require 'telegram/bot'

class TelegramBot

  def initialize
    @token = '508393177:AAGG3cuRIIb1OHfRq1IuvE1QxtlIAp1Djas' # lavaworkbot
  end

  def call
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        @message = message
        @bot = bot
        @resident = init_resident
        @resident.update_attribute(:telegram_id, message.from.id) if @resident.present? && @resident.telegram_id.nil?

        puts "#{message.from.username} => #{message.text}"

        case message.text
        when '/start'
          process_start
        # when  /\/phone/
        #   @resident = Resident.find_by(phone: message.text.split(' ').last) # FIXME небезопасно
        #   process_phone
        when '/days'
          process_days
        when /\/send/
          process_send
        else
          send_message(["У тебя все получится, детка, ебашь!", "Короче расслабься", "К тебе или ко мне?", "Ну шо епта", "Коворкинг - это образ жизни", "Просто напиши ей/ему", "Держи вкурсе", "Ave Maria - Deus Vult", "Ой, да займись ты уже делом", "я бот, а ты урод", "продолжай", "ладно, поигрались и хватит. Надоел уже!"].sample)
        end
      end
    end
  end

  protected

  def process_send
    # /send @quilok 3
    send_message("Ваш аккаунт не найден") unless @resident.present?
    cmd, receiver, days = @message.text.split(' ')
    days = days.try(:to_i)
    unless receiver.is_a?(String) && days.is_a?(Fixnum) && days > 0
      send_message("Правильный формат '/send <Telegram получателя> <дни>'")
      return
    end

    answer = TransferDaysService.call(@resident, receiver, days)
    send_message(answer)
  end

  def process_days
    if @resident.present?
      send_message("У вас осталось #{@resident.days} дней коворкинга")
    else
      send_message("Аккаунт не найден")
    end
  end

  def process_phone
    if @resident.present?
      @resident.update_attributes(telegram_id: @message.chat.id)
      send_message("#{@resident.first_name}, ваш аккаунт активирован. Пишите /help для справки.")
    else
      send_message("Аккаунт не найден")
    end
  end

  def process_start
    if @resident.present?
      send_message("Привет, #{@resident.first_name}!")
    else
      send_message("Привет, друг! Это телеграм-бот коворкинга Lavawork. Отправь мне свой номер командой /phone +7xxxxxxxxxx и я активирую твой аккаунт.")
    end
  end

  def init_resident
    if @message.from.username.present?
      Resident.find_by(telegram_username: @message.from.username)
    else
      Resident.find_by(telegram_id: @message.from.id)
    end
  end

  def send_message(text)
    @bot.api.send_message(chat_id: @message.chat.id, text: text)
  end
end

TelegramBot.new.call