require 'telegram/bot'

token = '464755633:AAEaMe6xAtQm6-_b3f6TVouIBCZ4oMlToVU' # lavawork bot

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts "#{message.chat.id} => #{message.text}"

    case message.text
    when '/start'
      resident = Resident.find_by(telegram_id: message.chat.id)

      if resident.present?
        bot.api.send_message(chat_id: message.chat.id, text: "Привет, #{resident.first_name}!")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Привет, друг! Это телеграм-бот коворкинга Lavawork. Отправь мне свой номер командой /phone +7xxxxxxxxxx и я активирую твой аккаунт.")
      end
    when  /\/phone/
      phone = message.text.split(' ').last
      resident = Resident.find_by(phone: phone)

      if resident.present?
        resident.update_attributes(telegram_id: message.chat.id)
        bot.api.send_message(chat_id: message.chat.id, text: "#{resident.first_name}, ваш аккаунт активирован. Пишите /help для справки.")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Аккаунт не найден")
      end
    when '/help'
      bot.api.send_message(chat_id: message.chat.id, text: "Команды: /days - узнать количество дней коворкинга, /help - увидеть это сообщение, /phone +7хххххххххх - сменить номер.")
    when '/days'
      resident = Resident.find_by(telegram_id: message.chat.id)
      if resident.present?
        bot.api.send_message(chat_id: message.chat.id, text: "У вас осталось #{resident.days} дней коворкинга")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Аккаунт не найден")
      end
    # when 'базарь'
      # answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['базарь'], one_time_keyboard: true)
      # bot.api.send_message(chat_id: message.chat.id, text: 'Сам базарь!', reply_markup: answers)
    else
      bot.api.send_message(chat_id: message.chat.id, text: "У тебя все получится, детка, ебашь!")
    end
  end
end
