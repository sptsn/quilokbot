require 'telegram/bot'

class TelegramBot

  def initialize
    @token = '464755633:AAEaMe6xAtQm6-_b3f6TVouIBCZ4oMlToVU' # lavawork_bot
  end

  def call
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        @message = message
        @bot = bot
        @resident = init_resident

        puts "#{message.from.username} => #{message.text}"

        case message.text
        when '/start'
          process_start
        # when  /\/phone/
        #   @resident = Resident.find_by(phone: message.text.split(' ').last) # FIXME небезопасно
        #   process_phone
        when '/days'
          process_days
        else
          send_message("У тебя все получится, детка, ебашь!")
        end
      end
    end
  end

  protected

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