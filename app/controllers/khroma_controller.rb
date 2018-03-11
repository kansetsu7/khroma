class KhromaController < ApplicationController
  before_action :set_category_list, only: [:pop_choices]

  def navbar
    categories = Category.includes(:types).where(gender_id: params[:id])

    render json: {
      html: render_to_string(partial: 'shared/navbar', locals: {categories: categories})
    }
  end

  def match
    # ---- Original ----------------------------------
    # type_up = Type.find(params[:up_type_id])
    # hue_level_up = HueLevel.find(params[:up_hue_level])

    # type_down = Type.find(params[:down_type_id])
    # hue_level_down = HueLevel.find(params[:down_hue_level])
    # render json: {
    #   productsUpMatchHtml: render_to_string(partial: 'shared/match_result', locals: {type: type_up, hue_level: hue_level_up}),
    #   productsDownMatchHtml: render_to_string(partial: 'shared/match_result', locals: {type: type_down, hue_level: hue_level_down})
    # }
    # ---- END Original ------------------------------    

# -------- new match algorithm -----------------------
    # ==== 開始進行配色 ================================
    # 至少要給一個category的type+hue_level & 另一個category的type才能進行配對
    if (params[:up_type_id].nil? || params[:up_hue_level]=='') && params[:down_hue_level]=='' ||
       (params[:down_type_id].nil? || params[:down_hue_level]=='') && params[:up_hue_level]==''
       # ---- TODO ----------------------------------        
       # 使用者給的參數不足，無法配色...
       # 給提示訊息告訴使用者至少要給一個category的type+hue_level & 另一個category的type才能進行配對
       # ---- END TODO -------------------------------
    
    else  # 參數足夠，可以進行配對

      # puts 是方便觀察用的，可以刪掉
      puts "up_type_id: #{params[:up_type_id]}"
      puts "up_hue_level: #{params[:up_hue_level]}"
      puts "down_type_id: #{params[:down_type_id]}"
      puts "down_hue_level: #{params[:down_hue_level]}"

      
      if params[:up_hue_level] == '' || params[:down_hue_level] == ''  # 有個hue_level沒給 => 提供使用者顏色、該顏色衣服以及配色法則
        # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, match_hue2以及principle_id
        # 可用來提供使用者顏色、該顏色衣服以及配色法則

        if params[:up_hue_level] == ''  # 
          hue_level = params[:down_hue_level].to_i
          type_with_hue_level = params[:down_type_id]
          type_without_hue_level = params[:up_type_id]
        else
          hue_level = params[:up_hue_level].to_i 
          type_with_hue_level = params[:up_type_id]
          type_without_hue_level = params[:down_type_id]         
        end

        hue_level = params[:up_hue_level] == '' ? params[:down_hue_level].to_i : params[:up_hue_level].to_i
        @principle_colors = PrincipleColor.where(hue_level_id: hue_level)  # 從提供的hue_level找到多筆對應PrincipleColor
        @principle_colors.each_with_index do |principle_color, i|
          no_match2 = principle_color.match2_hue_level.nil?
          # ---- TODO ----------------------------------
          # 1.提供使用者顏色: 
          #   1-1. principle_color.match1_hue_level.name, 
          #   1-2. principle_color.match2_hue_level.name (如果no_match2就不用給)
          # 2.提供使用者該顏色衣服:
          #   2-1. Type.find(type_with_hue_level).products.joins(:color).where('colors.hue_level_id = ?', hue_level)  # 有給顏色的type
          #   2-2. Type.find(type_without_hue_level).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match1_hue_level)  # 沒給顏色的type(要配色的)
          #   2-3. Type.find(type_without_hue_level).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match2_hue_level)  # 沒給顏色的type(要配色的)(如果no_match2就不用給)
          #   2-4. 如果沒有該顏色的衣服: 告訴使用者找不到該顏色的衣服
          # 3.提供使用者配色法則: 
          #   3-1. principle_color.principle.name
          #   3-2. principle_color.principle.image  # 圖片製作中...
          # ---- END TODO -------------------------------
        end

      else  # 兩個hue_level都有

        # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, match_hue2以及principle_id
        # 依照狀況提供使用者顏色、該顏色衣服以及配色法則（或是提示沒有符合的法則）
                
        # rel_table參考資料: https://stackoverflow.com/questions/3639656/activerecord-or-query
        # @principle_colors查詢說明:
        #   第一個where: 找hue_level_id符合上衣顏色的PrincipleColor
        #   第二個where: 看hue_match1或是hue_match2是否等於褲子顏色
        #   得到結果: 包含上衣和褲子顏色的PrincipleColor資料，可從principle_color.principle得知這兩個衣服符合什麼配色法則

        pc = PrincipleColor.arel_table
        @principle_colors = PrincipleColor.where(hue_level_id: params[:up_hue_level]).where(
          pc[:hue_match1].eq(params[:down_hue_level]).or(pc[:hue_match2].eq(params[:down_hue_level])))

        if @principle_colors.nil?  # 沒有符合的配色法則
          # ---- TODO ----------------------------------
          # 1.提供使用者顏色: 
          #   1-1. HueLevel.find(params[:up_hue_level])
          #   1-2. HueLevel.find(params[:down_hue_level])
          # 2.提供使用者該顏色衣服:
          #   2-1. Type.find(params[:up_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:up_hue_level])
          #   2-2. Type.find(params[:down_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:down_hue_level])
          #   2-3. 如果沒有該顏色的衣服: 告訴使用者找不到該顏色的衣服
          # 3.提示沒有符合的配色法則: 可能丟個提示語句之類的？
          # ---- END TODO -------------------------------

        else  # 有符合的法則
          @principle_colors.each_with_index do |principle_color, i|
            # ---- TODO ----------------------------------
            # 1.提供使用者顏色: 
            #   1-1. HueLevel.find(params[:up_hue_level])
            #   1-2. HueLevel.find(params[:down_hue_level])
            # 2.提供使用者該顏色衣服:
            #   2-1. Type.find(params[:up_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:up_hue_level])
            #   2-2. Type.find(params[:down_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:down_hue_level])
            #   2-3. 如果沒有該顏色的衣服: 告訴使用者找不到該顏色的衣服
            # 3.提供使用者配色法則: principle_color.principle.name
            #   3-1. principle_color.principle.image  # 圖片製作中...
            # ---- END TODO -------------------------------
          end
        end
      end
    end
# -------------------- END of new match algorithm ----------------
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
