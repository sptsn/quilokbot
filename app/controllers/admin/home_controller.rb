class Admin::HomeController < Admin::BaseController

  helper_method :residents_collection

  def index
  end

  protected

  def residents_collection
    @residents_collection ||= Resident.all
  end

end