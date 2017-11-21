class TransferDaysService

  def self.call(sender, receiver, days)
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
