class TelegramWorker
  include Sidekiq::Worker

  def perform
    puts 'telegram worker!'
    Telegram::BotService.new.call
  end

end
