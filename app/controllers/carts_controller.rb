class CartsController < ApplicationController

  before_action :authenticate_user!

  def create
    @product = Product.find_by_id(params[:product_id])
    cart = current_user.carts.build(product_id: params[:product_id])
    cart.save
  end

  def destroy
    @product = Product.find_by_id(params[:id])
    cart =current_user.carts.where(product_id: params[:id])
    cart.destroy_all
  end

  def index
    @user = current_user
    @types= []
    @products = current_user.cart_products.includes(style: :type)
    @types = @products.map{ |p| p.style.type.name }.uniq
  end

end
