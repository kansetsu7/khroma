class TypesController < ApplicationController

  def index
    @types = Type.where(category_id: params[:category_id])
  end

  def price_order_desc
    type = Type.find(params[:id])
    @styles = type.styles.joins(:products).group("styles.id").order("avg(products.price) DESC")
  end

  def price_order_asc
    type = Type.find(params[:id])
    @styles = type.styles.joins(:products).group("styles.id").order("avg(products.price) ASC")
  end

  def brand_order
    type = Type.find(params[:id])
    @styles = type.styles.joins(:products).group("styles.id").order("lower(products.brand) asc")
  end

end
