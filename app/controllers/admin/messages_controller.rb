class Admin::MessagesController < Admin::BaseController

  helper_method :residents_collection

  def index
  end

  def send_message
    res = TelegramService.new.send_message(text: message_params[:text], chat_id: message_params[:chat_id])

    if res.status == 200
      flash[:success] = 'Message sent'
    else
      flash[:error] = "#{JSON.parse(res.body)['error_code']} #{JSON.parse(res.body)['description']}"
    end

    redirect_to admin_messages_path
  end

  protected

  def message_params
    params.fetch(:message, {})
  end

  def residents_collection
    @residents_collection ||= Resident.active.map{|r|[r.decorate.display_name, r.telegram_id]}
  end

end