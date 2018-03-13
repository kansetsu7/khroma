class StylesController < ApplicationController

  def index
    @styles = Style.where(type_id: params[:type_id]).includes(:products, :colors)
  end

  def change_color
    @color = Color.find(params[:id])
    @product = @color.product
  end
end
