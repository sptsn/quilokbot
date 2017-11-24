class UnauthorizedResidentError < StandardError; end

class Telegram::BotLogic

  include Telegram::Redis # /lib
  include Telegram::ProcessMessages # /lib

  def call(args)
    @resident = Resident.find_by(telegram_username: args[:from]) # TODO rename to sender
    @message = args[:text]

    raise UnauthorizedResidentError unless @resident.present?

    current_command = if !@message.in?(['/cancel', '/residents']) && @resident.telegram_id.in?($redis.keys)
      redis_value['state']
    else
      @message.split('/').second
    end

    answer = send "process_#{current_command}"
  rescue NoMethodError => e
    puts e
    answer = process_random_message
  rescue UnauthorizedResidentError => e
    puts e
    answer = 'Ваш аккаунт не найден'
  ensure
    answer
  end

end
