class Match

  attr_reader :errors, :principles, :top_colors, :bottom_colors, :optional_colors,
              :top_products, :bottom_products, :outfits
  
  def initialize(top_type, top_hue_level, bottom_type, bottom_hue_level)
    @top_type        = top_type
    @top_hue_level   = top_hue_level
    @bottom_type      = bottom_type
    @bottom_hue_level = bottom_hue_level
    puts "#{top_type}, #{top_hue_level} x #{bottom_type}, #{bottom_hue_level}"
    @no_params = {'top_type' => top_type == '99',
                  'top_hue_level' => top_hue_level == '99',
                  'bottom_type' => bottom_type == '99',
                  'bottom_hue_level' => bottom_hue_level == '99'
                 }
    # matches[i][0][0]: 配色法則名稱
    # matches[i][0][1]: 配色法則圖片
    # matches[i][1][0]: 上半身的顏色
    # matches[i][1][1]: 下半身的顏色
    # matches[i][1][2]: 額外可選的顏色
    # matches[i][1][3]: 上半身顏色的hex
    # matches[i][1][4]: 下半身顏色的hex
    # matches[i][1][5]: 額外可選顏色的hex
    # matches[i][2][0]: 上半身的衣服
    # matches[i][2][1]: 下半身的衣服

    @errors = []
    @principles = []
    @top_colors = []
    @bottom_colors = []
    @optional_colors = []
    @top_products = []
    @bottom_products = []
    @outfits = []

    set_attributes
  end

  # 至少要給一個category的type+hue_level才能進行配對
  def enough_params?   
    (!@no_params['top_type'] && !@no_params['top_hue_level']) || (!@no_params['bottom_type'] && !@no_params['bottom_hue_level']) ? true : false
  end

  def puts_attributes_count
    puts '====================================='
    puts "@errors #{@errors.count}"
    puts "@principles #{@principles.count}"
    puts "@top_colors #{@top_colors.count}"
    puts "@bottom_colors #{@bottom_colors.count}"
    puts "@optional_colors #{@optional_colors.count}"
    puts "@top_products #{@top_products.count}"
    puts "@bottom_products #{@bottom_products.count}"
    @outfits.each_with_index do |outfit, i|
      outfit.each do |oft|
        puts "i: #{i}, outfit_id: #{oft.id}"
      end
    end
    puts '====================================='
  end

  private

  def set_attributes

    unless enough_params?
      @errors = ['參數不足，無法配色。至少要給半身的服裝與顏色才能進行配對']
      return
    end

    if @no_params['top_hue_level'] || @no_params['bottom_hue_level']  # 有個hue_level沒給 => 提供使用者顏色、該顏色衣服以及配色法則
      # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, match_hue2以及principle_id
      # 可用來提供使用者顏色、該顏色衣服以及配色法則
      if @no_params['top_hue_level']
        hue_level = @bottom_hue_level.to_i
        type_with_color = @bottom_type
        type_without_color = @no_params['top_type'] ? -1 : @top_type
      else
        hue_level = @top_hue_level.to_i 
        type_with_color = @top_type
        type_without_color = @no_params['bottom_type'] ? -1 : @bottom_type         
      end
      
      @principle_colors = PrincipleColor.where(hue_level_id: hue_level)  # 從提供的hue_level找到多筆對應PrincipleColor

      @principle_colors.each do |principle_color|
        set_principles(principle_color.principle)
        set_colors_with_one_hue(hue_level, principle_color)
        set_products_with_one_hue(type_with_color, type_without_color, hue_level, principle_color)
        set_outfits(principle_color)
      end

    else
      # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, option1_hue_level, option2_hue_level以及principle_id
      # 依照狀況提供使用者顏色、該顏色衣服以及配色法則（或是提示沒有符合的法則）
              
      # rel_table參考資料: https://stackoverflow.com/questions/3639656/activerecord-or-query
      # @principle_colors查詢說明:
      #   第一個where: 找hue_level_id符合上衣顏色的PrincipleColor
      #   第二個where: 看hue_match1或是hue_option1是否等於褲子顏色
      #   得到結果: 包含上衣和褲子顏色的PrincipleColor資料，可從principle_color.principle得知這兩個衣服符合什麼配色法則

      pc = PrincipleColor.arel_table
      @principle_colors = PrincipleColor.where(hue_level_id: @top_hue_level).where(
        pc[:hue_match1].eq(@bottom_hue_level).or(pc[:hue_option1].eq(@bottom_hue_level)))

      if @principle_colors.count == 0  # 沒有符合的配色法則(兩色都給的時候可能會發生)
        set_principles(Principle.find(7))
        set_colors_with_two_hue
        set_products_with_two_hue
      else
        @principle_colors.each do |principle_color|
          set_principles(principle_color.principle)
          set_colors_with_two_hue(principle_color.option1_hue_level, principle_color.option2_hue_level)
          set_products_with_two_hue
          set_outfits(principle_color)
        end
      end
    end
  end

  def set_outfits(principle_color)

    ok_outfits = []

    if @no_params['top_type']
      bottom_category_id = Type.find(@bottom_type).category.id  # 有給type的category
      top_category_id = bottom_category_id - 1
      gender_id = Type.find(@bottom_type).gender.id  # 有給type的gender
    elsif @no_params['bottom_type']
      top_category_id = Type.find(@top_type).category.id  # 有給type的category
      bottom_category_id = top_category_id + 1
      gender_id = Type.find(@top_type).gender.id  # 有給type的gender
    else
      top_category_id    = Type.find(@top_type).category.id
      bottom_category_id = Type.find(@bottom_type).category.id
      gender_id          = Type.find(@top_type).gender.id  # 有給type的gender
    end

    if @no_params['top_hue_level']
      top_hue_level    = principle_color.hue_level_id
      bottom_hue_level = principle_color.hue_match1
    elsif @no_params['bottom_hue_level']
      top_hue_level    = principle_color.hue_match1
      bottom_hue_level = principle_color.hue_level_id
    else
      top_hue_level    = @top_hue_level.to_i
      bottom_hue_level = @bottom_hue_level.to_i
    end
    puts "principle_color #{principle_color.id}"
    puts "top: #{top_category_id}, #{top_hue_level}"
    puts "bottom: #{bottom_category_id}, #{bottom_hue_level}"

    @outfits.push(principle_color.outfits.joins(:celebrity).where('celebrities.gender_id = ?', gender_id))

    # outfits = principle_color.outfits.joins(:celebrity).where('celebrities.gender_id = ?', gender_id)
    # puts "=== principle_color #{principle_color.principle.name} ============"
    # outfits.each_with_index do |outfit, i|
    #   got_top = false
    #   got_bottom = false
    #   outfit.products.each_with_index do |product, j|
    #     got_top    = true if product.color.hue_level_id == top_hue_level && product.category.id == top_category_id
    #     got_bottom = true if product.color.hue_level_id == bottom_hue_level && product.category.id == bottom_category_id
    #     puts "#{product.color.hue_level_id}, #{top_hue_level}, #{product.category.id}, #{top_category_id}"
    #     puts "#{product.color.hue_level_id}, #{bottom_hue_level}, #{product.category.id}, #{bottom_category_id}"
    #     puts "#{got_top}, #{got_bottom}"
    #   end

    #   outfit.virtual_products.each_with_index do |product, j|
    #     got_top    = true if product.color.hue_level_id == top_hue_level && product.category.id == top_category_id
    #     got_bottom = true if product.color.hue_level_id == bottom_hue_level && product.category.id == bottom_category_id
    #     puts "#{product.color.hue_level_id}, #{top_hue_level}, #{product.category.id}, #{top_category_id}"
    #     puts "#{product.color.hue_level_id}, #{bottom_hue_level}, #{product.category.id}, #{bottom_category_id}"
    #     puts "#{got_top}, #{got_bottom}"
    #   end

    #   if got_top && got_bottom
    #     ok_outfits.push(outfit)
    #   end
    # end
    # @outfits.push(ok_outfits)
  end

  def set_products_with_one_hue(type_with_color, type_without_color, hue_level, principle_color)
    product_of_given_color = Type.find(type_with_color).products.joins(:color).where('colors.hue_level_id = ?', hue_level)
    if type_without_color == -1  # 沒給type -> 從category找products
      # 從有給type的category反推找出沒給的category
      category_id = Type.find(type_with_color).category.id  # 有給type的category
      category_id = category_id.even? ? (category_id - 1) : (category_id + 1)  # 有給type的category.id是偶數 -> 沒給的是奇數
      product_of_match_color = Category.find(category_id).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match1_hue_level.id).limit(10)
    else  # 有給type
      product_of_match_color = Type.find(type_without_color).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match1_hue_level.id).limit(10)             
    end

    if @no_params['top_hue_level']
      @top_products.push(product_of_match_color)  # 上半身的衣服
      @bottom_products.push(product_of_given_color)  # 下半身的衣服
    else
      @top_products.push(product_of_given_color)  # 上半身的衣服
      @bottom_products.push(product_of_match_color)  # 下半身的衣服
    end
  end

  def set_products_with_two_hue
    if @no_params['top_type']

      category_id = Type.find(@bottom_type).category.id  # 有給type的category
      category_id = category_id.even? ? (category_id - 1) : (category_id + 1)  # 有給type的category.id是偶數 -> 沒給的是奇數
      @top_products.push(Category.find(category_id).products.joins(:color).where('colors.hue_level_id = ?', @top_hue_level).limit(10))
      @bottom_products.push(Type.find(@bottom_type).products.joins(:color).where('colors.hue_level_id = ?', @bottom_hue_level).limit(10))

    elsif @no_params['bottom_type']
      category_id = Type.find(@top_type).category.id  # 有給type的category
      category_id = category_id.even? ? (category_id - 1) : (category_id + 1)  # 有給type的category.id是偶數 -> 沒給的是奇數
      @bottom_products.push(Category.find(category_id).products.joins(:color).where('colors.hue_level_id = ?', @bottom_hue_level).limit(10))
      @top_products.push(Type.find(@top_type).products.joins(:color).where('colors.hue_level_id = ?', @top_hue_level).limit(10))

    else

      @top_products.push(Type.find(@top_type).products.joins(:color).where('colors.hue_level_id = ?', @top_hue_level).limit(10))
      @bottom_products.push(Type.find(@bottom_type).products.joins(:color).where('colors.hue_level_id = ?', @bottom_hue_level).limit(10))
    
    end
  end

  def set_colors_with_one_hue(hue_level, principle_color)
    top_hue_level = @no_params['top_hue_level'] ? principle_color.match1_hue_level : HueLevel.find(hue_level)
    bottom_hue_level = @no_params['top_hue_level'] ? HueLevel.find(hue_level) : principle_color.match1_hue_level
    optional_hlv1 = principle_color.option1_hue_level  # 可能為nil
    optional_hlv2 = principle_color.option2_hue_level  # 可能為nil

    @top_colors.push(top_hue_level)
    @bottom_colors.push(bottom_hue_level)
    @optional_colors.push([optional_hlv1, optional_hlv2])
  end

  def set_colors_with_two_hue(optional_hlv1 = nil, optional_hlv2 = nil)
    @top_colors.push(HueLevel.find(@top_hue_level))
    @bottom_colors.push(HueLevel.find(@bottom_hue_level))
    @optional_colors.push([optional_hlv1, optional_hlv2])
  end

  def set_principles(principle)
    @principles.push(principle)
  end

  # def method_name
  #   # ---- TODO ----------------------------------        
  #   # 使用者給的參數不足，無法配色...
  #   # 給提示訊息告訴使用者至少要給一個category的type+hue_level才能進行配對
  #   # ---- END TODO -------------------------------

    
  #   # 參數足夠，可以進行配對

  #   # puts 是方便觀察用的，可以刪掉
  #   # puts "top_type_id: #{@top_type}"
  #   # puts "top_hue_level: #{@top_hue_level}"
  #   # puts "bottom_type_id: #{@bottom_type}"
  #   # puts "bottom_hue_level: #{@bottom_hue_level}"
  #   matches = []
    
  #   if @no_params['top_hue_level'] || @no_params['bottom_hue_level']  # 有個hue_level沒給 => 提供使用者顏色、該顏色衣服以及配色法則

  #     # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, match_hue2以及principle_id
  #     # 可用來提供使用者顏色、該顏色衣服以及配色法則
  #     if @no_params['top_hue_level']  # 
  #       hue_level = @bottom_hue_level.to_i
  #       type_with_color = @bottom_type
  #       type_without_hue_level = @no_params['top_type'] ? -1 : @top_type
  #     else
  #       hue_level = @top_hue_level.to_i 
  #       type_with_color = @top_type
  #       type_without_hue_level = @no_params['bottom_type'] ? -1 : @bottom_type         
  #     end
  #     @principle_colors = PrincipleColor.where(hue_level_id: hue_level)  # 從提供的hue_level找到多筆對應PrincipleColor
  #     @principle_colors.each do |principle_color|    

  #       result = []
  #       # 1.配色法則 -------------
  #       # result_arr[0]: 配色法則
  #       #  - result_arr[0][0]: 配色法則的名稱
  #       #  - result_arr[0][1]: 配色法則的圖片
  #       result.push([principle_color.principle.name, principle_color.principle.image])
        
  #       # 2.符合法則的配色顏色 -------------
  #       # result_arr[1] = color_names: 符合法則的配色顏色
  #       #  - result_arr[1][0] = 上半身的顏色
  #       #  - result_arr[1][1] = 下半身的顏色
  #       #  - result_arr[1][2] = 額外可選的顏色
  #       #  - result_arr[1][3] = 上半身顏色的hex
  #       #  - result_arr[1][4] = 下半身顏色的hex
  #       #  - result_arr[1][5] = 額外可選顏色的hex

  #       color_names = []
  #       top_hue_level = @no_params['top_hue_level'] ? principle_color.match1_hue_level : HueLevel.find(hue_level)
  #       bottom_hue_level = @no_params['top_hue_level'] ? HueLevel.find(hue_level) : principle_color.match1_hue_level
  #       optional_hlv_name = principle_color.option1_hue_level.nil? ? nil : principle_color.option1_hue_level.name
  #       optional_hlv_hex = principle_color.option1_hue_level.nil? ? nil : principle_color.option1_hue_level.hex

  #       color_names.push(top_hue_level.name)          # 上半身的顏色
  #       color_names.push(bottom_hue_level.name)   # 下半身的顏色
  #       color_names.push(optional_hlv_name)          # 額外可選的顏色
  #       color_names.push(top_hue_level.hex)       # 上半身顏色的hex
  #       color_names.push(bottom_hue_level.hex)    # 下半身顏色的hex
  #       color_names.push(optional_hlv_hex)  # 下半身顏色的hex
  #       result.push(color_names)
        
  #       # 3.配色顏色的衣服 -------------
  #       # result_arr[2] = products: 配色顏色的衣服
  #       #  - result_arr[2][0] = 上半身的衣服
  #       #  - result_arr[2][1] = 下半身的衣服
  #       products = []
  #       product_of_given_color = Type.find(type_with_color).products.joins(:color).where('colors.hue_level_id = ?', hue_level)
  #       if type_without_hue_level == -1  # 沒給type -> 從category找products
  #         # 從有給type的category反推找出沒給的category
  #         category_id = Type.find(type_with_color).category.id  # 有給type的category
  #         category_id = category_id.even? ? (category_id - 1) : (category_id + 1)  # 有給type的category.id是偶數 -> 沒給的是奇數
  #         product_of_match_color = Category.find(category_id).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match1_hue_level.id).limit(10)
  #       else  # 有給type
  #         product_of_match_color = Type.find(type_without_hue_level).products.joins(:color).where('colors.hue_level_id = ?', principle_color.match1_hue_level.id).limit(10)             
  #       end
  #       if @no_params['top_hue_level']
  #         products.push(product_of_match_color)  # 上半身的衣服
  #         products.push(product_of_given_color)  # 下半身的衣服
  #       else
  #         products.push(product_of_given_color)  # 上半身的衣服
  #         products.push(product_of_match_color)  # 下半身的衣服
  #       end
  #       result.push(products)
  #       matches.push(result)           
  #     end
  #     # matches[i][0][0]: 配色法則名稱
  #     # matches[i][0][1]: 配色法則圖片
  #     # matches[i][1][0]: 上半身的顏色
  #     # matches[i][1][1]: 下半身的顏色
  #     # matches[i][1][2]: 額外可選的顏色
  #     # matches[i][1][3]: 上半身顏色的hex
  #     # matches[i][1][4]: 下半身顏色的hex
  #     # matches[i][1][5]: 額外可選顏色的hex
  #     # matches[i][2][0]: 上半身的衣服
  #     # matches[i][2][1]: 下半身的衣服
  #     render json: {
  #       productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
  #     }

  #   else  # 兩個hue_level都有

  #     # 找出hue_level_id符合的PrincipleColor資料, 可得match_hue1, match_hue2以及principle_id
  #     # 依照狀況提供使用者顏色、該顏色衣服以及配色法則（或是提示沒有符合的法則）
              
  #     # rel_table參考資料: https://stackoverflow.com/questions/3639656/activerecord-or-query
  #     # @principle_colors查詢說明:
  #     #   第一個where: 找hue_level_id符合上衣顏色的PrincipleColor
  #     #   第二個where: 看hue_match1或是hue_option1是否等於褲子顏色
  #     #   得到結果: 包含上衣和褲子顏色的PrincipleColor資料，可從principle_color.principle得知這兩個衣服符合什麼配色法則

  #     pc = PrincipleColor.arel_table
  #     @principle_colors = PrincipleColor.where(hue_level_id: @top_hue_level).where(
  #       pc[:hue_match1].eq(@bottom_hue_level).or(pc[:hue_option1].eq(@bottom_hue_level)))

  #     if @principle_colors.count == 0  # 沒有符合的配色法則
  #       result = []
  #       # 1.配色法則 -------------
  #       # result_arr[0]: 配色法則
  #       #  - result_arr[0][0]: 配色法則的名稱
  #       #  - result_arr[0][1]: 配色法則的圖片  # 圖片製作中...
  #       result.push(['沒有符合的配色法則', ''])

  #       # 2.符合法則的配色顏色 => 用使用者給的顏色-------------
  #       # result_arr[1] = color_names: 符合法則的配色顏色
  #       #  - result_arr[1][0] = 上半身的顏色
  #       #  - result_arr[1][1] = 下半身的顏色
  #       #  - result_arr[1][2] = nil(沒有額外可選的顏色)
  #       #  - result_arr[1][3] = 上半身顏色的hex
  #       #  - result_arr[1][4] = 下半身顏色的hex
  #       #  - result_arr[1][5] = nil(沒額外可選顏色的hex)
  #       top_hue_level      = HueLevel.find(@top_hue_level)
  #       bottom_hue_level   = HueLevel.find(@bottom_hue_level)
  #       color_names = [top_hue_level.name, bottom_hue_level.name, nil,
  #                      top_hue_level.hex, bottom_hue_level.hex, nil]
  #       result.push(color_names)
        
  #       # 3.配色顏色的衣服 -------------
  #       # result_arr[2] = products: 配色顏色的衣服
  #       #  - result_arr[2][0] = 上半身的衣服
  #       #  - result_arr[2][1] = 下半身的衣服
  #       products = []
  #       top_products    = Type.find(@top_type).products.joins(:color).where('colors.hue_level_id = ?', @top_hue_level).limit(10)
  #       bottom_products = Type.find(@bottom_type).products.joins(:color).where('colors.hue_level_id = ?', @bottom_hue_level).limit(10)
  #       products = [top_products, bottom_products]
  #       result.push(products)

  #       matches.push(result) 
            
  #       render json: {
  #         productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
  #       }

  #     else  # 有符合的法則

  #       @principle_colors.each_with_index do |principle_color, i|
  #         if principle_color.match2_hue_level.nil?
  #           second_option = [nil, nil]
  #         else
  #           second_option = principle_color.match1_hue_level.id == @bottom_hue_level.to_i ? principle_color.match2_hue_level : principle_color.match1_hue_level
  #           second_option = [second_option.name, second_option.hex]
  #         end 

  #         result = []
  #         # 1.配色法則 -------------
  #         # result_arr[0]: 配色法則
  #         #  - result_arr[0][0]: 配色法則的名稱
  #         #  - result_arr[0][1]: 配色法則的圖片  # 圖片製作中...
  #         result.push([principle_color.principle.name, principle_color.principle.image])

  #         # 2.符合法則的配色顏色 -------------
  #         # result_arr[1] = color_names: 符合法則的配色顏色
  #         #  - result_arr[1][0] = 上半身的顏色
  #         #  - result_arr[1][1] = 下半身的顏色
  #         #  - result_arr[1][2] = 額外可選的顏色
  #         #  - result_arr[1][3] = 上半身顏色的hex
  #         #  - result_arr[1][4] = 下半身顏色的hex
  #         #  - result_arr[1][5] = 額外可選顏色的hex

  #         top_hue_level      = HueLevel.find(@top_hue_level)
  #         bottom_hue_level   = HueLevel.find(@bottom_hue_level)

  #         color_names = []
  #         color_names.push(top_hue_level.name)  # 上半身的顏色
  #         color_names.push(bottom_hue_level.name)  # 下半身的顏色 
  #         color_names.push(second_option[0])  # 額外可選的顏色
  #         color_names.push(top_hue_level.hex)  # 上半身的顏色
  #         color_names.push(bottom_hue_level.hex)  # 下半身的顏色 
  #         color_names.push(second_option[1])  # 額外可選的顏色
  #         result.push(color_names)
          
  #         # 3.配色顏色的衣服 -------------
  #         # result_arr[2] = products: 配色顏色的衣服
  #         #  - result_arr[2][0] = 上半身的衣服
  #         #  - result_arr[2][1] = 下半身的衣服
  #         products = []
  #         product_top = Type.find(@top_type).products.joins(:color).where('colors.hue_level_id = ?', @top_hue_level).limit(10)
  #         product_of_bottom = Type.find(@bottom_type).products.joins(:color).where('colors.hue_level_id = ?', @bottom_hue_level).limit(10)
  #         result.push([product_top, product_of_bottom])

  #         matches.push(result)  

  #         render json: {
  #           productsMatchHtml: render_to_string(partial: 'shared/match_result', locals: {matches: matches})
  #         }         
  #       end
  #     end
  #   end
  # end

  
end
