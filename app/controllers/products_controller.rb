class ProductsController < ApplicationController
  before_action :set_current_style, only: [:change_style_previous, :change_style_next]


  def show
    @product = Product.find(params[:id])
  end

  def change_color
    @color = Color.find(params[:id])
    @product = @color.product
  end

  def change_style_next
    if @current_index == (@styles_id.length - 1)
      @current_index = -1
    end
    next_style = Style.find(@styles_id[@current_index+1])
    @product = next_style.products.first

    render "change_color" 
  end

  def change_style_previous
    if @current_index == 0
      @current_index = @styles_id.length
    end
    previous_style = Style.find(@styles_id[@current_index-1])
    @product = previous_style.products.first

    render "change_color" 
  end

  def family
    product = Product.find(params[:id])
    @products = product.style.type.products.joins(:color).where("colors.hue_level_id = ?", product.color.hue_level_id).includes(color: :hue_level, style: :type).limit(10)

    render json: { familyHtml: render_to_string( partial: "shared/family_row", local: {products: product} ) }
  end

  private

    def set_current_style
      current_product = Product.find(params[:id])
      current_style = current_product.style
      type = current_style.type
      styles = type.styles
      @styles_id = []
      @current_index = 0
      
      styles.each_with_index do |style, i|
        @styles_id << style.id

        if style.id == current_style.id
          @current_index = i
        end
      end
    end

end
