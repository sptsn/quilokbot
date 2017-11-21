require 'telegram/bot'

# days - узнать количество дней коворкинга
# residents - список резидентов
# send - отправить дни другому резиденту

class UnauthorizedResidentError < StandardError; end

class TelegramBot
  include Telegram::Redis
  include Telegram::ProcessMessages

  def initialize
    @token = '508393177:AAGG3cuRIIb1OHfRq1IuvE1QxtlIAp1Djas' # lavaworkbot
  end

  def call
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        begin
          @message = message
          @bot = bot
          @resident = Resident.find_by(telegram_username: message.from.username)
          raise UnauthorizedResidentError unless @resident.present?
          @resident.update_attribute(:telegram_id, message.from.id) unless @resident.telegram_id

          puts "#{message.from.username} => #{message.text}"

          current_command = if !message.text.in?(['/cancel', '/residents']) && @resident.telegram_id.in?($redis.keys)
            redis_value['state']
          else
            message.text.split('/').second
          end

          answer = send "process_#{current_command}"
        rescue NoMethodError
          answer = process_random_message
        rescue UnauthorizedResidentError
          answer = 'Ваш аккаунт не найден'
        ensure
          send_message answer
        end
      end
    end
  end

  protected

  def send_message(text)
    @bot.api.send_message(chat_id: @message.chat.id, text: text)
  end

end

TelegramBot.new.call
