class StylesController < ApplicationController
  before_action :set_type, except: [:change_color]

  def index
    @styles = Style.where(type_id: params[:type_id]).includes(:products, :colors).order(created_at: :desc).page(params[:page]).per(20)
  end

  def price_order_asc
    @styles = Style.where(type_id: params[:type_id]).includes(products: :color).includes(:colors).order("products.price ASC")
  end
  
  def price_order_desc
    @styles = Style.where(type_id: params[:type_id]).includes(products: :color).includes(:colors).order("products.price DESC")
  end

  def brand_order
    @styles = Style.where(type_id: params[:type_id]).includes(products: :color).includes(:colors).order("products.brand ASC").order("products.price ASC")
  end

  def change_color
    @color = Color.find(params[:id])
    @product = @color.product
  end

  private
    def set_type
      @type = Type.find(params[:type_id])
    end
end
