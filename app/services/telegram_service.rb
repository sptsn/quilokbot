class TelegramService

  def initialize
    @base_url = 'https://api.telegram.org/'
    @token = 'bot464755633:AAEaMe6xAtQm6-_b3f6TVouIBCZ4oMlToVU'
  end

  def send_message(args)
    connection.get 'sendMessage', text: args[:text], chat_id: args[:chat_id]
  end

  protected

  def connection
    @connection ||= Faraday.new(@base_url + @token)
  end

end