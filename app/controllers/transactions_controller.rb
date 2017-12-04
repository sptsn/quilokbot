class TransactionsController < ApplicationController

  helper_method :transactions_collection

  def index
  end

  protected

  def transactions_collection
    @transactions_collection ||= Transaction.ordered.page(params[:page]).decorate
  end

end