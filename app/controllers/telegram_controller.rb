class TelegramController < ApplicationController

  skip_before_action :verify_authenticity_token

  def message
    Telegram::SendMessageService.new.call(text: 'asdf', chat_id: '3002462')
    render nothing: true
  end

end
