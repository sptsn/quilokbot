require 'telegram/bot'

class UnauthorizedResidentError < StandardError; end

class TelegramBot

  # days - узнать количество дней коворкинга
  # residents - список резидентов
  # send - отправить дни другому резиденту

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

  def process_wait_for_days
    days = @message.text.to_i
    if days <= 0
      set_redis state: 'wait_for_days', receiver: redis_value['receiver']
      'Неверное значение'
    elsif @resident.days < days
      set_redis state: 'wait_for_days', receiver: redis_value['receiver']
      'У вас не хватает дней'
    else
      receiver = Resident.find_by(telegram_username: redis_value['receiver'])
      TransferDaysService.call(@resident, receiver, days)
      reset_redis
      "Перечислено #{days} дней пользователю #{receiver.decorate.display_name}"
    end
  end

  def process_wait_for_reveiver
    receiver = Resident.find_by(telegram_username: @message.text)
    if receiver.present?
      set_redis state: 'wait_for_days', receiver: @message.text
      'Укажите количество дней'
    else
      set_redis state: 'wait_for_reveiver'
      'Получатель не найден. Просмотрите список резидентов командой /residents или введите /cancel для отмены.'
    end
  end

  def set_redis(value)
    $redis.set @resident.telegram_id, value.to_json
  end

  def reset_redis
    $redis.del @resident.telegram_id
  end

  def redis_value
    JSON.parse $redis.get @resident.telegram_id
  end

  def process_cancel
    reset_redis
    "OK"
  end

  def process_random_message
    ["У тебя все получится, детка, ебашь!",
      "Короче расслабься",
      "К тебе или ко мне?",
      "Ну шо епта",
      "Коворкинг - это образ жизни",
      "Просто напиши ей/ему",
      "Держи вкурсе",
      "Ave Maria - Deus Vult",
      "Ой, да займись ты уже делом",
      "продолжай",
      "ладно, поигрались и хватит. Надоел уже!"].sample
  end

  def process_residents
    Resident.all.decorate.reduce(""){|memo, r| memo << r.display_name_with_telegram_username << "\n"}
  end

  def process_send
    set_redis state: 'wait_for_reveiver'
    "Укажите получателя"
  end

  def process_days
    "У вас осталось #{@resident.days} дней коворкинга"
  end

  def process_start
    "Привет, #{@resident.first_name}!"
  end
end

TelegramBot.new.call
