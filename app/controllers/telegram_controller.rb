class TelegramController < ApplicationController

  skip_before_action :verify_authenticity_token

  def recieve
    reciever = Resident.find_by(telegram_username: params[:message][:from][:username])
    reciever.update_attribute(:telegram_id, params[:message][:from][:id]) unless reciever.telegram_id

    answer = Telegram::BotLogic.new.call(from: params[:message][:from][:username], text: params[:message][:text])
    Telegram::SendMessageService.new.call(text: answer, chat_id: params[:message][:from][:id])
    render nothing: true
  end

end
