class KhromaController < ApplicationController
  before_action :set_category_list, only: [:index ,:pop_choices]

  def index
    @categories_init = []
    for i in 0...@category_list.length do
      for j in 0...@category_list[i].length
        type_names = []
        type_names << @category_list[i][j][:name]          
      end
      @categories_init[i] = Category.where(gender_id: 2, name: type_names)
    end
  end

  def navbar
    categories = Category.includes(:types).where(gender_id: params[:id])

    render json: {
      html: render_to_string(partial: 'shared/navbar', locals: {categories: categories})
    }
  end

  def match
    # 'Match' is a service object, app/service/match.rb
    @matches = Match.new(params[:up_type_id], params[:up_hue_level], params[:down_type_id], params[:down_hue_level])
    # @matches = Match.new(params[:up_type_id], params[:up_hue_level], params[:down_type_id], params[:down_hue_level], params[:principle_color_id])
    @matches.puts_attributes_count

    render json: {
      productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {principle_colors: @matches.principle_colors,
        top_color: @matches.top_color, bottom_color: @matches.bottom_color, optional_colors: @matches.optional_colors,
        top_products: @matches.top_products, bottom_products: @matches.bottom_products, outfits: @matches.outfits,
        target_principle: @matches.target_principle})
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
