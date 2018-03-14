class ProductsController < ApplicationController

  def index
    @style = Style.find(params[:style_id])
    @products = @style.products
  end

  def show
    @product = Product.find(params[:id])
  end

  def change_color
    @color = Color.find(params[:id])
    @product = @color.product
  end
end
