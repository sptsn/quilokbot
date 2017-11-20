class Admin::TransactionsController < Admin::BaseController

  helper_method :transactions_collection

  def index
  end

  protected

  def transactions_collection
    @transactions_collection ||= Transaction.order(created_at: :desc).decorate
  end

end