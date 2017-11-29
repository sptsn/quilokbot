class MessagesController < ApplicationController

  helper_method :residents_collection

  def index
  end

  def broadcast
  end

  def send_broadcast
    res = Resident.where(telegram_username: 'aspitsyn').map do |resident|
      send_message_service.call(text: message_params[:text], chat_id: resident.telegram_id)
    end

    if res.all?{|r| r.status == 200}
      flash[:success] = 'Messages sent'
    else
      flash[:error] = 'Something goes wrong'
    end

    redirect_to broadcast_path
  end

  def send_message
    res = send_message_service.call(text: message_params[:text], chat_id: message_params[:chat_id])

    if res.status == 200
      flash[:success] = 'Message sent'
    else
      flash[:error] = "#{JSON.parse(res.body)['error_code']} #{JSON.parse(res.body)['description']}"
    end

    redirect_to messages_path
  end

  protected

  def send_message_service
    @send_message_service ||= Telegram::SendMessageService.new
  end

  def message_params
    params.fetch(:message, {})
  end

  def residents_collection
    @residents_collection ||= Resident.active.map{|r|[r.decorate.display_name, r.telegram_id]}
  end

end
