class ProductsController < ApplicationController

  helper_method :resource_product, :products_collection

  def create
    if resource_product.save
      flash[:success] = 'Услуга сохранена'
      redirect_to products_path
    else
      render action: :new
    end
  end

  def update
    if resource_product.update_attributes(product_params)
      flash[:success] = 'Услуга обновлена'
      redirect_to products_path
    else
      render action: :edit
    end
  end

  def destroy
    resource_product.destroy
    redirect_to products_path
  end

  protected

  def resource_product
    @resource_product ||= params[:id].present? ? Product.find(params[:id]) : Product.new(product_params)
  end

  def product_params
    params.fetch(:product, {}).permit(:name, :description, :key)
  end

  def products_collection
    @products_collection ||= Product.order(:id)
  end

end
