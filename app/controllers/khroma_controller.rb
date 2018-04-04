class KhromaController < ApplicationController
  before_action :set_category_list, only: [ :pop_gender_choices, :pop_category_choices]

  def index
  end

  def navbar
  	categories = Category.includes(:types).where(gender_id: params[:id])

  	render json: {
  	  html: render_to_string(partial: 'shared/navbar', locals: {categories: categories})
  	}
  end

  def match
    # 'Match' is a service object, app/service/match.rb
    @matches = Match.new(params[:up_type_id], params[:up_hue_level], params[:down_type_id], params[:down_hue_level], params[:principle_color_id])
      puts "error = #{@matches.error}"
      puts @matches.error.any?
      puts @matches.error[:message].nil?
    if @matches.error.any?
      puts "yo error!"
      params_not_enough if @matches.error[:code] == 1
    end
    

    render json: {
      productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {principle_colors: @matches.principle_colors,
        top_color: @matches.top_color, bottom_color: @matches.bottom_color, optional_colors: @matches.optional_colors,
        top_products: @matches.top_products, bottom_products: @matches.bottom_products, outfits: @matches.outfits,
        target_principle: @matches.target_principle, error: @matches.error})
    }
  end

  def pop_gender_choices
  	render json:{
  	  typesUpHtml: render_to_string(partial: 'shared/pop_gender_choices', locals: {categories: @categories[0]}),
  	  typesDownHtml: render_to_string(partial: 'shared/pop_gender_choices', locals: {categories: @categories[1]})
  	}  
  end

  def pop_category_choices
    if params[:up_or_down] == "0" 
      q2 = 1
    else 
      q2 = 0
    end

  	render json: {
      q1Html: render_to_string(partial: 'shared/pop_q1_choices', locals: {categories: @categories[params[:up_or_down].to_i]}),
  		q2Html: render_to_string(partial: 'shared/pop_q2_choices', locals: {categories: @categories[q2]})
  	}	
  end

  private

  def set_category_list
	 category_list = [ [{name: '上衣類'}], [{name: '下身類'}] ]

    @categories = []
    for i in 0...category_list.length do
      for j in 0...category_list[i].length
        type_names = []
        type_names << category_list[i][j][:name]          
      end
    @categories[i] = Category.where(gender_id: params[:gender_id], name: type_names)
    end
  end
end
