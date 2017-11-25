module Telegram::ProcessMessages

  protected

  def process_residents
    Resident.all.decorate.reduce(""){|memo, r| memo << r.display_name_with_telegram_username << "\n"}
  end

  def process_send
    set_redis state: 'wait_for_receiver'
    "Укажите telegram-логин получателя"
  end

  def process_days
    "У вас осталось #{@resident.days} дней коворкинга"
  end

  def process_start
    "Привет, #{@resident.first_name}!"
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

  def process_wait_for_days
    days = @message.to_i
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

  def process_wait_for_receiver
    receiver = Resident.find_by(telegram_username: @message)

    if receiver.present?
      if receiver != resident
        set_redis state: 'wait_for_days', receiver: @message
        'Укажите количество дней'
      else
        set_redis state: 'wait_for_receiver'
        'Нельзя переводить дни самому себе'
      end
    else
      set_redis state: 'wait_for_receiver'
      'Получатель не найден. Просмотрите список резидентов командой /residents или введите /cancel для отмены.'
    end
  end

end
