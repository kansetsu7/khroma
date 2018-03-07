class KhromaController < ApplicationController

  def match
    styles_top = Style.where(type_id: params[:top_type_id])
    styles_top_id = []
    styles_top.each do |style_top|
      styles_top_id << style_top.id
    end
    @top_products = Product.where(style_id: styles_top_id, rough_color: params[:top_rough_color])

    styles_bottom = Style.where(type_id: params[:bottom_type_id])
    styles_bottom_id = []
    styles_bottom.each do |style_bottom|
      styles_bottom_id << style_bottom.id
    end
    @bottom_products = Product.where(style_id: styles_bottom_id, rough_color: params[:bottom_rough_color])
 
    render json: {
      productsTopMatchHtml: render_to_string(partial: 'shared/match_result', locals: {products: @top_products}),
      productsBottomMatchHtml: render_to_string(partial: 'shared/match_result', locals: {products: @bottom_products})
    }

  end

  def pop_choices
    categories_top = Category.where(gender_id: params[:gender_id], name:'top')
    categories_top_id = []
    categories_top.each do |category_top|
      categories_top_id << category_top.id
    end
    @types_top = Type.where(category_id: categories_top_id )

    categories_bottom= Category.where(gender_id: params[:gender_id], name: 'bottom') 
    categories_bottom_id = []
    categories_bottom.each do |category_bottom|
      categories_bottom_id << category_bottom.id
    end
    @types_bottom = Type.where(category_id: categories_bottom_id, )

    render json:{
      typesTopHtml: render_to_string(partial: 'shared/pop_choices', locals: {types_category: @types_top}),
      typesBottomHtml: render_to_string(partial: 'shared/pop_choices', locals: {types_category: @types_bottom})
    }
  end
end
