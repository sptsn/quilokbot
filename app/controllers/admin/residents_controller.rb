class Admin::ResidentsController < Admin::BaseController

  helper_method :resource_resident

  def new
  end

  def create
    if resource_resident.save
      flash[:success] = 'Resident created'
      redirect_to admin_path
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if resource_resident.update_attributes(resident_params)
      flash[:success] = 'Resident updated'
      redirect_to admin_path
    else
      render action: :edit
    end
  end

  def destroy
    resource_resident.destroy
    redirect_to admin_path
  end

  protected

  def resource_resident
    @resource_resident ||= params[:id].present? ? Resident.find(params[:id]) : Resident.new(resident_params)
  end

  def resident_params
    params.fetch(:resident, {}).permit!
  end

end