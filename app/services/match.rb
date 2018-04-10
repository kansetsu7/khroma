class Match

  attr_reader :error, :principle_colors, :top_color, :bottom_color, :optional_colors,
              :top_products, :bottom_products, :outfits, :target_principle_color,
              :target_principle
  
  def initialize(top_type, top_hue_level, bottom_type, bottom_hue_level, principle_color_id)
    @top_type           = top_type
    @top_hue_level      = top_hue_level
    @bottom_type        = bottom_type
    @bottom_hue_level   = bottom_hue_level
    @principle_color_id = principle_color_id

    @no_params = {'top_type' => top_type == '99' || top_type == '',
                  'top_hue_level' => top_hue_level == '99' || top_hue_level == '',
                  'bottom_type' => bottom_type == '99' || bottom_type == '',
                  'bottom_hue_level' => bottom_hue_level == '99' || bottom_hue_level == ''
                 }

    @error = {}
    @top_color
    @bottom_color
    @optional_colors = []
    @top_products
    @bottom_products
    @outfits = []

    set_principle_colors
    return if error.any?
    set_attributes
  end

  private

  # 至少要給一個category的type+hue_level才能進行配對
  def enough_params?   
    (!@no_params['top_type'] && !@no_params['top_hue_level'] && (!@no_params['bottom_type'] || @bottom_type == '99') ) || 
    (!@no_params['bottom_type'] && !@no_params['bottom_hue_level'] && !@no_params['top_type'] || @top_type == '99') ? true : false
  end

  # Just for debug
  def puts_attributes_count
    puts '====================================='
    puts "principle_colors #{@principle_colors.count}"
    puts "@principle_color_id #{@principle_color_id}"
    puts "@target_principle_color #{@target_principle_color.id}"
    puts "@target_principle #{target_principle.id}"
    puts "@optional_colors #{@optional_colors.count}"
    puts "@top_products #{@top_products.count}"
    puts "@bottom_products #{@bottom_products.count}"
    @outfits.each_with_index do |outfit, i|
      puts "i: #{i}, outfit_id: #{outfit.id}"
    end
    puts '====================================='
  end

  def set_principle_colors
    unless enough_params?
      @error = {code: 1, message: '參數不足，選單皆為必填'}
      return
    end

    gender_id = @no_params['top_type'] ? Type.find(@bottom_type).gender.id : Type.find(@top_type).gender.id

    if @no_params['top_hue_level']
      @hue_level = @bottom_hue_level.to_i
      pcs = PrincipleColor.where(hue_match1: @hue_level)
    else
      @hue_level = @top_hue_level.to_i 
      pcs = PrincipleColor.where(hue_level_id: @hue_level)
    end

    @principle_colors = []
    pcs.each_with_index do |principle_color, i|  # 只留有outfits的principle_colors
      @principle_colors.push(principle_color) unless principle_color.outfits.joins(:celebrity).where('celebrities.gender_id = ?', gender_id) == []
    end

    @target_principle_color = @principle_color_id.nil? ? @principle_colors.first : PrincipleColor.find(@principle_color_id)
    @target_principle = @target_principle_color.principle

  end

  def set_attributes
    set_colors
    set_products
    set_outfits
  end

  def set_outfits
    gender_id = @no_params['top_type'] ? Type.find(@bottom_type).gender.id : Type.find(@top_type).gender.id    
    @outfits = @target_principle_color.outfits.joins(:celebrity).where('celebrities.gender_id = ?', gender_id)
  end

  def get_product_of_match_color(type_with_color, type_without_color, match_hue_level_id)
    return Type.find(type_without_color).products.joins(:color).where('colors.hue_level_id = ?', match_hue_level_id).limit(10) unless type_without_color == '99'

    # 沒給type -> 從有給type的category反推找出沒給的category
    category_id = Type.find(type_with_color).category.id  # 有給type的category
    category_id = category_id.even? ? (category_id - 1) : (category_id + 1)  # 有給type的category.id是偶數 -> 沒給的是奇數
    Category.find(category_id).products.joins(:color).where('colors.hue_level_id = ?', match_hue_level_id)
    
  end

  def set_products
    if @no_params['top_hue_level']
      @bottom_products = Type.find(@bottom_type).products.joins(:color).where('colors.hue_level_id = ?', @bottom_hue_level.to_i).limit(10)
      @top_products = get_product_of_match_color(@bottom_type, @top_type, @target_principle_color.hue_level_id)
    else # no bottom_hue_level
      @top_products = Type.find(@top_type).products.joins(:color).where('colors.hue_level_id = ?', @top_hue_level.to_i).limit(10)
      @bottom_products = get_product_of_match_color(@top_type, @bottom_type, @target_principle_color.hue_match1)
    end
  end

  def set_colors
    @top_color = @no_params['top_hue_level'] ? @target_principle_color.match1_hue_level : HueLevel.find(@top_hue_level.to_i)
    @bottom_color = @no_params['top_hue_level'] ? @target_principle_color.match1_hue_level : HueLevel.find(@top_hue_level.to_i)
    optional_hlv1 = @target_principle_color.option1_hue_level  # 可能為nil
    optional_hlv2 = @target_principle_color.option2_hue_level  # 可能為nil
    @optional_colors = [optional_hlv1, optional_hlv2]
  end
  
end
