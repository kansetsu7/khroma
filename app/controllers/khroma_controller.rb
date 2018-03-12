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
      matches = []
      
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
        @principle_colors.each do |principle_color|

          # match_colors: 目前配色法則下的配色顏色，可能有１個或２個
          # match_colors[0]: 第一個配色match1_hue_level的顏色名稱與id
          # match_colors[1]: 第二個配色match2_hue_level的顏色名稱與id
          # match_colors[i][0]: 顏色名稱
          # match_colors[i][1]: 顏色id
          match_colors = []
          match_colors.push([principle_color.match1_hue_level.name, principle_color.match1_hue_level])
          match_colors.push([principle_color.match2_hue_level.name, principle_color.match2_hue_level]) unless principle_color.match2_hue_level.nil?

          match_colors.each_with_index do |color, i|
            result = []
            # 1.配色法則 -------------
            # result_arr[0]: 配色法則名稱
            result.push(principle_color.principle.name)

            # 2.符合法則的配色顏色 -------------
            # color_names[0] = 上半身的顏色
            # color_names[1] = 下半身的顏色
            color_names = []
            if params[:up_hue_level] == ''
              color_names.push(color[0])
              color_names.push(HueLevel.find(hue_level).name)
            else
              color_names.push(HueLevel.find(hue_level).name)
              color_names.push(color[0])
            end
            result.push(color_names)  # result_arr[1]: 符合法則的配色顏色
                                      # result_arr[1][0]: 上半身的顏色, result_arr[1][1]: 下半身的顏色
            
            # 3.配色顏色的衣服 -------------
            # products[0] = 上半身的衣服
            # products[1] = 下半身的衣服
            products = []
            product_of_given_color = Type.find(type_with_hue_level).products.joins(:color).where('colors.hue_level_id = ?', hue_level)
            product_of_match_color = Type.find(type_without_hue_level).products.joins(:color).where('colors.hue_level_id = ?', color[1])
            if params[:up_hue_level] == ''
              products.push(product_of_match_color)
              products.push(product_of_given_color)
            else
              products.push(product_of_given_color)
              products.push(product_of_match_color)
            end
            result.push(products)   # result_arr[2]: 配色顏色的衣服
                                    # result_arr[2][0]: 上半身的衣服, result_arr[2][1]: 下半身的衣服
            matches.push(result)           
          end
        end
        # matches[i][0]: 配色法則名稱
        # matches[i][1][0]: 上半身的顏色
        # matches[i][1][1]: 下半身的顏色
        # matches[i][2][0]: 上半身的衣服
        # matches[i][2][1]: 下半身的衣服
        
        # puts matches.size.to_s + " results -------"
        # matches.each_with_index do |match, i|
        #   puts "===== result #{i} ======="
        #   puts "配色法則名稱: #{match[0]}"
        #   puts "上半身的顏色: #{match[1][0]}"
        #   puts "下半身的顏色: #{match[1][1]}"
        #   puts "上半身的衣服: #{match[2][0].count} 件"
        #   puts "下半身的衣服: #{match[2][1].count} 件"
        # end

        render json: {
          productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
        }

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
puts "pcs: #{@principle_colors.count == 0}"
        if @principle_colors.count == 0  # 沒有符合的配色法則
          result = []
          # 1.配色法則 -------------
          # result_arr[0]: 配色法則名稱
          result.push('沒有符合的配色法則')

          # 2.符合法則的配色顏色 => 用使用者給的顏色-------------
          # color_names[0] = 上半身的顏色
          # color_names[1] = 下半身的顏色
          color_names = [HueLevel.find(params[:up_hue_level]).name, HueLevel.find(params[:down_hue_level]).name]
          result.push(color_names)  # result_arr[1]: 符合法則的配色顏色
                                    # result_arr[1][0]: 上半身的顏色, result_arr[1][1]: 下半身的顏色
          
          # 3.配色顏色的衣服 -------------
          # products[0] = 上半身的衣服
          # products[1] = 下半身的衣服
          products = []
          top_products    = Type.find(params[:up_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:up_hue_level])
          bottom_products = Type.find(params[:down_type_id]).products.joins(:color).where('colors.hue_level_id = ?', params[:down_hue_level])
          products = [top_products, bottom_products]
          result.push(products)   # result_arr[2]: 配色顏色的衣服
                                  # result_arr[2][0]: 上半身的衣服, result_arr[2][1]: 下半身的衣服
          matches.push(result) 
              
          render json: {
            productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
          }
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
