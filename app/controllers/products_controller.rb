class ProductsController < ApplicationController
  before_action :set_current_style, only: [:change_style_previous, :change_style_next]

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

  def change_style_next
    if @current_index == (@styles_id.length - 1)
      @current_index = -1
    end
    next_style = Style.find(@styles_id[@current_index+1])
    @product = next_style.products.first

    render file: "products/change_color.js.erb" 
  end

  def change_style_previous
    if @current_index == 0
      @current_index = @styles_id.length
    end
    previous_style = Style.find(@styles_id[@current_index-1])
    @product = previous_style.products.first

    render file: "products/change_color.js.erb" 
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
