class ClientsController < ApplicationController

  helper_method :resource_client, :clients_collection

  def index
  end

  def new
  end

  def create
    if resource_client.save
      flash[:success] = 'Client created'
      redirect_to require_userclients_path
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if resource_client.update_attributes(client_params)
      flash[:success] = 'Client updated'
      redirect_to clients_path
    else
      render action: :edit
    end
  end

  def destroy
    resource_client.destroy
    redirect_to clients_path
  end

  protected

  def clients_collection
    @clients_collection ||= Client.order(:id).decorate
  end

  def resource_client
    @resource_client ||= params[:id].present? ? Client.find(params[:id]) : Client.new(client_params)
  end

  def client_params
    params.fetch(:client, {}).permit!
  end

end
