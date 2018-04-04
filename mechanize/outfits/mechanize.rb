require 'mechanize'
require 'watir'
require 'watir-scroll'
require 'csv'
require 'yaml'
require 'cloudinary'

# gender(男裝) > category(上衣) > type(襯衫) > style(款式) > product
# ===== gender 不用抓，自己設定 =====
$genders_arr = ["men", "women"]
$n_genders = $genders_arr.size

def get_uniqlo_data
  # get_uniqlo_outfit_links
  # get_outfit_images
  # get_outfit_product
  # get_virtual_product_color
  # upload_color_chips
  # write_hue_level
  change_vp_hue_level
end

def change_vp_hue_level
  v_products = CSV.read("./outfit_virtual_product.txt")
  writer = CSV.open("./outfit_virtual_product.txt", "w")
  writer << ['outfit_id', 'category', 'link', 'color_chip_id', 'cloudinary chip link','RGB hex', 'hue_level']

  v_products.each_with_index do |v_product, i|
    next if i == 0
    puts "#{i} ===== #{v_products[i]}"
    if v_product[4] == '-1'
      writer << v_products[i]
    else
      v_product[6] = get_hue_level(v_product[5])
      writer << v_products[i]
    end
  end
end

def write_hue_level
  v_products = CSV.read("./outfit_virtual_product.txt")
  writer = CSV.open("./outfit_virtual_product.txt", "w")
  writer << ['outfit_id', 'category', 'link', 'color_chip_id', 'cloudinary chip link','RGB hex', 'hue_level']

  v_products.each_with_index do |v_product, i|
    next if i == 0
    puts "#{i} ====="
    if v_product[4] == '-1'
      writer << v_products[i]
    else
      v_products[i].push(get_hue_level(v_product[5]))
      writer << v_products[i]
    end
  end
end

def upload_color_chips
  color_links = CSV.read("./outfit_color.txt")
  v_products = CSV.read("./outfit_virtual_product.txt")

  auth = get_cloudinary_auth

  writer = CSV.open("./outfit_virtual_product.txt", "w")
  writer << ['outfit_id', 'category', 'link', 'color_chip_id', 'cloudinary chip link','RGB hex']
  
  v_products.each_with_index do |v_product, i|
    next if i == 0
    puts "#{i} ====="
    if color_links[i][1] == '-1'
      writer << v_products[i].push('-1')
    else
      url = upload_cloudinary(auth, color_links[i][1], 'vp'+color_links[i][0])
      puts "image uploaded!"
      color = get_cloudinary_color(auth, 'vp'+color_links[i][0])
      puts "got color!"
      v_products[i].push(url)
      v_products[i].push(color)
      writer << v_products[i]
    end
  end
end

def get_cloudinary_color(auth, public_id)
  auth[:colors] = true
  colors = []

  result = Cloudinary::Api.resource(public_id, auth)
  result_colors = result['colors']
  result_colors.first[0]
  # result_colors.each_with_index do |rc, i|
  #   colors.push(rc[0])
  #   colors.push(rc[1])
  #   puts "#{i}, #{rc[0]}, #{rc[1]}"
  # end
  # colors
end

def upload_cloudinary(auth, image, public_id)
  auth[:public_id] = public_id
  result = Cloudinary::Uploader.upload(image, auth)
  result['url']
end

def get_cloudinary_auth
  content = YAML.load_file("../../config/cloudinary.yml")
  config = {}
  config[:cloud_name] = content['development']['cloud_name']
  config[:api_key] = content['development']['api_key']
  config[:api_secret] = content['development']['api_secret']
  config
end

def get_virtual_product_color
  v_products = CSV.read("./outfit_virtual_product.txt")
  outfits = CSV.read("./outfit_link.txt")
  writer = CSV.open("./outfit_color.txt", "a+")
  # writer << ['virtual_product_id','color_chip_link']

  v_products.each_with_index do |v_product, i|
    next if i == 0 || i <= 1969
    puts "#{i} ===="
    if skip_color(v_product[1], outfits[v_product[0].to_i+1][1])
      writer << [i-1, -1]
    else
      color = get_page(v_product[2], '', true, false).search("li[color='#{v_product[3]}'] img")
      if color.count == 0
        writer << [i-1, -1]
      else
        writer << [i-1, color.first['src']]
      end
    end
  end
end

def skip_color(category, link)
  category = category.to_i
  return true if category == -1
  gender = link.split('%2F')[1]
  # puts "#{gender} #{category}"
  return true if gender == 'men' && category > 1
  return true if gender == 'women' && category < 2
  false
end

def get_outfit_images
  in_arr = CSV.read("./outfit_link.txt")
  writer = CSV.open("./outfit_link.txt", "a+")
  writer << ['=========================']
  in_arr.each_with_index do |outfit, i|
    next if i == 0
    puts "outfit #{outfit[0]}"
    link = 'http://www.uniqlo.com/tw/stylingbook' + outfit[1][1..-1]
    image = get_page(link, 'div.modelArea>img', false, false).search('div.modelArea>img')
    outfit[2] = image.first['src']
    writer << outfit
    # puts image.first['src']

  end
end

def get_outfit_product

  uniqlo_products = CSV.read("../uniqlo/products0_renamed.txt")

  in_arr = CSV.read("./outfit_link.txt")

  op_writer = CSV.open("./outfit_product.txt", "a+")
  # op_writer << ['outfit_id', 'product_id']

  ovp_writer = CSV.open("./outfit_virtual_product.txt", "a+")
  # ovp_writer << ['outfit_id', 'category', 'link', 'color_chip_id']

  in_arr.each_with_index do |outfit_link, i|
    next if i == 0 || i < 408
    puts "outfit #{outfit_link[0]}"
    link = 'http://www.uniqlo.com/tw/stylingbook' + outfit_link[1][1..-1]
    products = get_page(link, 'div.itemArea>dl', false, false).search('div.itemArea>dl')

    products.each_with_index do |product, j|
      unless product.search('img').count == 0
        sn = product.search('img').first['src'].split('/').last.sub!('_small', '')
        product_id = find_product(sn, uniqlo_products)
        if product_id == -1
          category = get_category(product.search('dt.name').first.text.strip)
          link = 'http://www.uniqlo.com/tw/store/goods/' + product.search('img').first['src'].split('/')[-3]
          ovp_writer << [i-1, category, link, sn[0..1]]
        else
          op_writer << [i-1, product_id]
        end
      end      
    end
  end
end

def get_category(name)
  top_names = ['恤', '背心', 'polo', '衫', '衣', '袖', '外套']
  if name.include?('男')
    return 1 if name.include?('褲')
    
    top_names.each do |top_name|
      return 0 if name.include?(top_name)
    end
  else
    return 3 if name.include?('褲')
    return 3 if name.include?('裙')
    return 3 if name.include?('洋裝')
    
    top_names.each do |top_name|
      return 2 if name.include?(top_name)
    end
  end

  -1
end

def find_product(sn, products)
  products.each_with_index do |product, i|
    next if i == 0
    product_sn = product[4].split('/').last
    return i-1 if product_sn == sn
  end
  -1
end

def get_uniqlo_outfit_links
  puts "==== get_uniqlo_outfit_links ===="

  writer = CSV.open("./outfit_link.txt", "w")
  writer << ['id', 'link']
  id = 0

  $genders_arr.each do |gender|
    outfit_links = get_page("http://www.uniqlo.com/tw/stylingbook/#/#{gender}/", false, 'div#modelWrap>ul>li>a', true).search('div#modelWrap>ul>li>a')
    outfit_links.each_with_index do |outfit_link, i|
      writer << [id, outfit_link['href'], get_img_link(outfit_link.search('img').first['src'])]
      id += 1
    end
  end
end

def get_img_link(thumb_link)
  file_name = thumb_link.split('/').last
  xxm_file_name = file_name.split('-')[0] + '-xxm.jpg'
  'http://www.uniqlo.com' + thumb_link.sub!(file_name, xxm_file_name)
end

def get_page(link, check_content, skip_check, scroll)
  puts "goto #{link}"
  timeout = 0
  no_content = 0
  n_refresh = 0

  begin
    browser = Watir::Browser.new :safari  # open safari
    browser.goto(link)
  rescue Exception => e
    puts "===== Exception #{Time.now.strftime("%d/%m/%Y %H:%M")} ====="
    timeout += 1
    if timeout <= 5
      system %{ osascript -e 'tell application "Safari" to quit'}  # close safari
      sleep(10)
      retry
    end
  end

  loop do
    break if skip_check || Nokogiri::HTML.fragment(browser.html).search(check_content).size != 0
    if no_content < 4
      sleep(2)
      no_content += 1
    else
      browser.refresh
      no_content = 0
      n_refresh += 1
    end
    return nil if n_refresh == 3
  end

  if scroll
    browser.scroll.to :bottom  # scroll to bottom to get more images
    sleep(5)
  else
    sleep(1)
  end  
  page = Nokogiri::HTML.fragment(browser.html)
  browser.close
  # system %{ osascript -e 'tell application "Safari" to quit'}  # close safari
  page

end

class Color

  attr_reader :rgy_r, :ryb_y, :ryb_b, :h, :s, :v

  def initialize(rgb_hex)
    @rgb_r = rgb_hex[1, 2].to_i(16)
    @rgb_g = rgb_hex[3, 2].to_i(16)
    @rgb_b = rgb_hex[5, 2].to_i(16)

    ryb = self.to_ryb
    @ryb_r = ryb[0]
    @ryb_y = ryb[1]
    @ryb_b = ryb[2]

    # hsv = self.to_ryb_base_hsv
    hsv = self.to_rgb_base_hsv
    @h = hsv[0]
    @s = hsv[1]
    @v = hsv[2]
  end

  def to_ryb
    # Remove the white from the color

    iWhite = [@rgb_r, @rgb_g, @rgb_b].min.to_f
    
    iRed   = @rgb_r.to_f - iWhite
    iGreen = @rgb_g.to_f - iWhite
    iBlue  = @rgb_b.to_f - iWhite
    
    iMaxGreen = [iRed, iGreen, iBlue].max
    
    # Get the yellow out of the red+green
    
    iYellow = [iRed, iGreen].min
    
    iRed   -= iYellow
    iGreen -= iYellow
    
    # If this unfortunate conversion combines blue and green, then cut each in half to
    # preserve the value's maximum range.
    if iBlue > 0 && iGreen > 0
      iBlue  /= 2
      iGreen /= 2
    end
    
    # Redistribute the remaining green.
    iYellow += iGreen
    iBlue   += iGreen
    
    # Normalize to values.
    iMaxYellow = [iRed, iYellow, iBlue].max
    
    if iMaxYellow > 0
      iN = iMaxGreen / iMaxYellow;
      
      iRed    *= iN
      iYellow *= iN
      iBlue   *= iN
    end
    
    # Add the white back in.
    iRed    += iWhite
    iYellow += iWhite
    iBlue   += iWhite
    
    [iRed.floor, iYellow.floor, iBlue.floor]
  end

  def to_ryb_hex
    ryb = self.to_ryb
    "##{@ryb_r.to_s(16).rjust(2, '0')}#{@ryb_y.to_s(16).rjust(2, '0')}#{@ryb_b.to_s(16).rjust(2, '0')}"
  end

  def to_ryb_base_hsv
    ri = @ryb_r / 255.0
    yi = @ryb_y / 255.0
    bi = @ryb_b / 255.0

    cmax = [ri, yi, bi].max
    cmin = [ri, yi, bi].min
    delta = cmax - cmin

    # HSV Calculation
    # Hue calculation
    if delta == 0
      h = 0
    elsif cmax == ri
      h = 60 * (((yi - bi) / delta) % 6)
    elsif cmax == yi
      h = 60 * (((bi - ri)/ delta) + 2)
    elsif cmax == bi
      h = 60 * (((ri - yi)/ delta) + 4)
    end

    # Saturation calculation
    if (cmax == 0)
      s = 0
    else
      s = delta / cmax * 100
    end

    # Value calculation
    v = cmax * 100

    [h.round(2), s.round(2), v.round(2)]
  end

  def to_rgb_base_hsv
    ri = @rgb_r / 255.0
    gi = @rgb_g / 255.0
    bi = @rgb_b / 255.0

    cmax = [ri, gi, bi].max
    cmin = [ri, gi, bi].min
    delta = cmax - cmin

    # HSV Calculation
    # Hue calculation
    if delta == 0
      h = 0
    elsif cmax == ri
      h = 60 * (((gi - bi) / delta) % 6)
    elsif cmax == gi
      h = 60 * (((bi - ri)/ delta) + 2)
    elsif cmax == bi
      h = 60 * (((ri - gi)/ delta) + 4)
    end

    # Saturation calculation
    if (cmax == 0)
      s = 0
    else
      s = delta / cmax * 100
    end

    # Value calculation
    v = cmax * 100
    [kuler_hue(h), s, v]    
  end

  def mapRange(value, fromLower, fromUpper, toLower, toUpper)
    (toLower + (value - fromLower) * ((toUpper - toLower) / (fromUpper - fromLower)))
  end

  def kuler_hue(in_hue)
    # mapping RGB hue to adobe kuler's color wheel's hue
    # scientificToArtisticSmooth
    # source: https://github.com/benknight/kuler-d3/blob/master/colorwheel.js
    # UI http://benknight.github.io/kuler-d3/

    return in_hue * (60.0 / 35.0) if in_hue < 35.0
    return mapRange(in_hue, 35.0,  60.0, 60.0,  122.0)  if in_hue < 60.0
    return mapRange(in_hue, 60.0,  120.0, 122.0, 165.0) if in_hue < 120.0
    return mapRange(in_hue, 120.0, 180.0, 165.0, 218.0) if in_hue < 180.0
    return mapRange(in_hue, 180.0, 240.0, 218.0, 275.0) if in_hue < 240.0
    return mapRange(in_hue, 240.0, 300.0, 275.0, 330.0) if in_hue < 300.0
           mapRange(in_hue, 300.0, 360.0, 330.0, 360.0)
  end

  def is_achromatic?
    s < 7 || v <= 20 ? true : false
  end
end

def get_hue_level(rgb_hex)
  c = Color.new(rgb_hex)
  # ---- achromatic 無色彩 ----
  
  return 13 if c.s < 7 || c.v <= 20

  # ---- chromatic ----
  # hue_level,  hue range
  # 1,          hue < 15 || hue >= 345
  # 2,          15 <= hue < 45
  # 3,          45 <= hue < 75
  # ...
  # 11,         285 <= hue < 315
  # 12,         315 <= hue < 345
  for hue_level in 2..12 do
    return hue_level if c.h >= 15 + 30 * (hue_level - 2) && c.h < 45 + 30 * (hue_level - 2)
  end

  return 1
end
# ------------------
get_uniqlo_data
