class Admin::BaseController < ApplicationController

  layout 'admin'

  before_filter :require_user

  def require_user
    redirect_to sign_in_url if current_user.nil?
  end

end