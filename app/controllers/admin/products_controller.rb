class Admin::ProductsController < ApplicationController

  def index
    @style = Style.find(params[:style_id])
    @products = @style.products
    @product = Product.new

  end

  def create
    @product = Product.new(product_params)
    @product.style_id = params[:style_id]
    @product.save
    redirect_to admin_style_products_path
  end

  def edit
    @product = Product.find(params[:id])
    @style = Style.find(params[:style_id])
  end

  def update
    @product = Product.find(params[:id])
    @product.update(product_params)
    @product.save
    redirect_to admin_style_products_path
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_style_products_path
  end

  private
  def product_params
    params.require(:product).permit(:name, :image, :link, :price, :brand)
  end
  
end
