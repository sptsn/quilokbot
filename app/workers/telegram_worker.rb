require 'telegram/bot'

class TelegramBot

  # days - узнать количество дней коворкинга
  # residents - список резидентов
  # send - отправить дни другому резиденту

  def initialize
    @token = '508393177:AAGG3cuRIIb1OHfRq1IuvE1QxtlIAp1Djas' # lavaworkbot
    @commands = %w(
      start
      days
      send
      residents
      cancel
    )
    @send_sub_commands = %w(
      wait_for_days
      wait_for_reveiver
    )
  end

  def call
    Telegram::Bot::Client.run(@token) do |bot|
      bot.listen do |message|
        @message = message
        @bot = bot
        @resident = init_resident
        @resident.update_attribute(:telegram_id, message.from.id) if @resident.telegram_id&.nil?

        puts "#{message.from.username} => #{message.text}"

        if !message.text.in?(['/cancel', '/residents']) && @resident.telegram_id.in?($redis.keys)
          send "process_#{redis_value['state']}"
        else
          cmd = message.text.split('/').second
          if cmd.in? @commands
            send "process_#{cmd}"
          else
            process_random_message
          end
        end
      end
    end
  end

  protected

  def process_wait_for_days
    days = @message.text.to_i
    if days <= 0
      send_message 'Неверное значение'
      set_redis state: 'wait_for_days', receiver: redis_value['receiver']
    elsif @resident.days < days
      send_message 'У вас не хватает дней'
      set_redis state: 'wait_for_days', receiver: redis_value['receiver']
    else
      send_message TransferDaysService.call(@resident, Resident.find_by(telegram_username: redis_value['receiver']), days)
      reset_redis
    end
  end

  def process_wait_for_reveiver
    receiver = Resident.find_by(telegram_username: @message.text)
    if receiver.present?
      set_redis state: 'wait_for_days', receiver: @message.text
      send_message 'Укажите количество дней'
    else
      set_redis state: 'wait_for_reveiver'
      send_message 'Получатель не найден. Просмотрите список резидентов командой /residents или введите /cancel для отмены.'
    end
  end

  def set_redis(value)
    $redis.set @resident.telegram_id, value.to_json
  end

  def reset_redis
    $redis.del @resident.telegram_id
  end

  def redis_value
    JSON.parse $redis[@resident.telegram_id]
  end

  def process_cancel
    reset_redis
    send_message "OK"
  end

  def process_random_message
    send_message(["У тебя все получится, детка, ебашь!", "Короче расслабься", "К тебе или ко мне?", "Ну шо епта", "Коворкинг - это образ жизни", "Просто напиши ей/ему", "Держи вкурсе", "Ave Maria - Deus Vult", "Ой, да займись ты уже делом", "я бот, а ты урод", "продолжай", "ладно, поигрались и хватит. Надоел уже!"].sample)
  end

  def process_residents
    send_message Resident.all.decorate.reduce(""){|memo, r| memo << r.display_name_with_telegram_username << "\n"}
  end

  def process_send
    set_redis state: 'wait_for_reveiver'
    send_message("Укажите получателя")
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
