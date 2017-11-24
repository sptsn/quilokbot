class TelegramController < ApplicationController

  skip_before_action :verify_authenticity_token

  def message
    answer = Telegram::BotLogic.new.call(from: params[:message][:from][:username], text: params[:message][:text])
    Telegram::SendMessageService.new.call(text: answer, chat_id: params[:message][:from][:id])
    render nothing: true
  end

end
