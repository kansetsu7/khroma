class KhromaController < ApplicationController
  before_action :set_category_list, only: [:pop_choices]

  def match
    styles_up = Style.where(type_id: params[:up_type_id])
    colors_up = Color.where(hue_level_id: params[:up_hue_level])

    styles_down = Style.where(type_id: params[:down_type_id])
    colors_down = Color.where(hue_level_id: params[:down_hue_level])    

    # styles_top = Style.where(type_id: params[:top_type_id])
    # styles_top_id = []
    # styles_top.each do |style_top|
    #   styles_top_id << style_top.id
    # end
    
    # colors
    # @top_products = Product.where(style_id: styles_top_id, rough_color: params[:top_rough_color])

    # styles_bottom = Style.where(type_id: params[:bottom_type_id])
    # styles_bottom_id = []
    # styles_bottom.each do |style_bottom|
    #   styles_bottom_id << style_bottom.id
    # end
    # @bottom_products = Product.where(style_id: styles_bottom_id, rough_color: params[:bottom_rough_color])
 
    render json: {
      productsTopMatchHtml: render_to_string(partial: 'shared/match_result', locals: {styles: styles_up, colors: colors_up}),
      productsBottomMatchHtml: render_to_string(partial: 'shared/match_result', locals: {styles: styles_down, colors: colors_down})
    }

  end

  def pop_choices
    categories = []
    for i in 0...@category_list.length do
      for j in 0...@category_list[i].length
        type_names = []
        type_names << @category_list[i][j][:name]          
      end
      categories[i] = Category.where(gender_id: params[:gender_id], name: type_names)
    end

    render json:{
      typesUpHtml: render_to_string(partial: 'shared/pop_choices', locals: {categories: categories[0]}),
      typesDownHtml: render_to_string(partial: 'shared/pop_choices', locals: {categories: categories[1]})
    }
  end

  private

  def set_category_list
    @category_list = [ [{name: 'top'}], [{name: 'bottom'}] ]
  end
end
