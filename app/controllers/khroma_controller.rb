class KhromaController < ApplicationController
  before_action :set_category_list, only: [:pop_choices]

  def navbar
    categories = Category.includes(:types).where(gender_id: params[:id])

    render json: {
      html: render_to_string(partial: 'shared/navbar', locals: {categories: categories})
    }
  end

  def match
    type_up = Type.includes(products: :color).find(params[:up_type_id])
    hue_level_up = HueLevel.find(params[:up_hue_level])

    type_down = Type.includes(products: :color).find(params[:down_type_id])
    hue_level_down = HueLevel.find(params[:down_hue_level])    

    render json: {
      productsUpMatchHtml: render_to_string(partial: 'shared/match_result', locals: {type: type_up, hue_level: hue_level_up}),
      productsDownMatchHtml: render_to_string(partial: 'shared/match_result', locals: {type: type_down, hue_level: hue_level_down})
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
    @category_list = [ [{name: '上衣類'}], [{name: '下身類'}] ]
  end
end
