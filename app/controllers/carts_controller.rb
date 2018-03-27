class CartsController < ApplicationController

  before_action :authenticate_user!

  def create
    cart = current_user.carts.build(product_id: params[:product_id])
    cart.save
    redirect_back(fallback_location: root_path)

  end

  def destroy
    cart =current_user.carts.where(product_id: params[:id])
    cart.destroy_all
    redirect_back(fallback_location: root_path)

  end

end
