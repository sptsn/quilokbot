class OrdersController < ApplicationController

  helper_method :orders_collection

  def index
  end

  def check
    puts params
    resource_order.check
    resource_order.save
    flash[:success] = 'Заявка отмечена как просмотренная'
    redirect_to orders_path
  end

  protected

  def resource_order
    @resource_order ||= Order.find(params[:order_id])
  end

  def orders_collection
    @orders_collection ||= Order.ordered.decorate
  end

end
