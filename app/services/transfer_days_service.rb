class TransferDaysService

  def self.call(sender, receiver_username, days)
    receiver = Resident.find_by(telegram_username: receiver_username)

    return 'У вас не хватает дней' if sender.days < days
    return 'Получатель не найден' if receiver.nil?

    ActiveRecord::Base.transaction do
      sender.decrement_days! days
      receiver.increment_days! days
      Transaction.create(
        receiver_id: receiver.id,
        sender_id: sender.id,
        days: days
      )
    end

    "Перечислено #{days} дней пользователю #{receiver.decorate.display_name}"
  end

end