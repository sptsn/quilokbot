class TelegramService

  def initialize
    @base_url = 'https://api.telegram.org/'
    @token = 'bot508393177:AAGG3cuRIIb1OHfRq1IuvE1QxtlIAp1Djas'
  end

  def send_message(args)
    connection.get 'sendMessage', text: args[:text], chat_id: args[:chat_id]
  end

  protected

  def connection
    @connection ||= Faraday.new(@base_url + @token)
  end

end