class MessagesController < ApplicationController

  helper_method :clients_collection

  def index
  end

  def broadcast
  end

  def send_broadcast
    res = Client.all.map do |client|
      bot.send_message(text: message_params[:text], chat_id: client.telegram_id)
    end

    if res.all?{|r| r['ok']}
      flash[:success] = 'Messages sent'
    else
      flash[:error] = 'Something goes wrong'
    end

    redirect_to broadcast_path
  end

  def send_message
    res = bot.send_message(text: message_params[:text], chat_id: message_params[:chat_id])

    if res['ok']
      flash[:success] = 'Message sent'
    else
      flash[:error] = "#{JSON.parse(res.body)['error_code']} #{JSON.parse(res.body)['description']}"
    end

    redirect_to messages_path
  end

  protected

  def bot
    @bot ||= Telegram.bot
  end

  def send_message_service
    @send_message_service ||= Telegram::SendMessageService.new
  end

  def message_params
    params.fetch(:message, {})
  end

  def clients_collection
    @clients_collection ||= Client.all.map{|r|[r.decorate.display_name, r.telegram_id]}
  end

end
