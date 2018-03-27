class StylesController < ApplicationController
  before_action :set_type, except: [:change_color]

  def index
    @styles = Style.where(type_id: params[:type_id]).includes(:products, :colors).order(created_at: :desc).page(params[:page]).per(20)
    render_json
  end

  def price_order_asc
    @styles = Style.where(type_id: params[:type_id]).includes(products: :color).includes(:colors).order("products.price ASC").page(params[:page]).per(20)
    render_json
  end
  
  def price_order_desc
    @styles = Style.where(type_id: params[:type_id]).includes(products: :color).includes(:colors).order("products.price DESC").page(params[:page]).per(20)
    render_json
  end

  def brand_order
    @styles = Style.where(type_id: params[:type_id]).includes(products: :color).includes(:colors).order("products.brand ASC").order("products.price ASC").page(params[:page]).per(20)
    render_json
  end

  def change_color
    @color = Color.find(params[:id])
    @product = @color.product
  end

  private
    def set_type
      @type = Type.find(params[:type_id])
    end

    def render_json
    if params[:page].to_i > 1
      render json: { 
        html: render_to_string(partial: "shared/product_sm", collection: @styles, as: :style),
        paginateHtml: render_to_string(partial: "shared/paginate", locals: { styles: @styles} )
      }
    end
  end
end
