class TelegramWorker
  include Sidekiq::Worker

  def perform
    puts 'telegram worker!'
    TelegramBot.new.call
  end

end
