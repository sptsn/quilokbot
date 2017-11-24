class Telegram::SendMessageService

  def initialize
    @base_url = 'https://api.telegram.org/'
  end

  def call(args)
    connection.get 'sendMessage', text: args[:text], chat_id: args[:chat_id]
  end

  protected

  def connection
    @connection ||= Faraday.new(@base_url + "bot#{$token}")
  end

end
