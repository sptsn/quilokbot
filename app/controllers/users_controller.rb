class UsersController < ApplicationController

  helper_method :users_collection, :resource_user

  def index
  end

  def update
    if resource_user.update_attributes(user_params)
      flash[:success] = 'Админ обновлен'
      redirect_to users_path
    else
      render action: :edit
    end
  end

  def destroy
    resource_user.destroy
    redirect_to users_path
  end

  protected

  def users_collection
    @users_collection ||= User.all.decorate
  end

  def resource_user
    @resource_user ||= params[:id].present? ? User.find(params[:id]) : User.new(user_params)
  end

  def user_params
    params.fetch(:user, {}).permit!
  end

end
