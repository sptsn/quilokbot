require 'telegram/bot'

# days - узнать количество дней коворкинга
# residents - список резидентов
# send - отправить дни другому резиденту

class Telegram::BotService

  def call
    ::Telegram::Bot::Client.run($token) do |bot|
      bot.listen do |message|

        puts "#{message.from.username} => #{message.text}"

        resident = Resident.find_by(telegram_username: message.from.username)
        resident.update_attribute(:telegram_id, message.from.id) unless resident.telegram_id

        answer = Telegram::BotLogic.new.call(from: message.from.username, text: message.text)
        bot.api.send_message(chat_id: message.chat.id, text: answer)
      end
    end
  end

end
