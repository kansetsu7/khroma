require 'rest_client'
require 'base64'
require 'json'
require 'csv'
require 'yaml'
require 'cloudinary'

def write_color
  in_arr = CSV.read("./color.txt")
  writer = CSV.open("./clothes_color.txt", "wt")
  writer <<['product_id', 'rgb hex', 'ryb hex', 'percentage of clothes', 'hue_level']
  arr_hlv = Array.new(13, 0) # array for count hue levels arr_hlv[0] stands for hue_level 1 etc.
  in_arr.each_with_index do |color, i| 
    next if i == 0  # skip first row 

    c = Color.new(color[1])
    if c.is_achromatic?
      main_color = color[3].nil? ? color[1] : color[3]
      percentage = color[3].nil? ? color[2] : color[4]
    else  
      main_color = color[1]
      percentage = color[2]
    end

    c = Color.new(main_color)
    hlv = get_hue_level(main_color)
    arr_hlv[hlv-1] += 1 
    writer << [i, main_color, c.to_ryb_hex, percentage, hlv]
  end

  arr_hlv.each_with_index do |n, i|
    puts "#{i+1}: #{n}"
  end
end

def get_color
  in_arr = CSV.read("./products0_renamed.txt")

  # -------content of in_arr -----------
  # in_arr[i][0] = type_id
  # in_arr[i][1] = name
  # in_arr[i][2] = link
  # in_arr[i][3] = color
  # in_arr[i][4] = image_link
  # in_arr[i][5] = gender_id
  # in_arr[i][6] = category_of_gender_id
  # in_arr[i][7] = type_of_category_id
  # in_arr[i][8] = style_of_type_id
  # ------------------------------------

  auth = get_cloudinary_auth

  writer = CSV.open("./color.txt", "a+")
  # writer << ["product_id", "color"]
  in_arr.each_with_index do |product, i|
    next if i == 0 || i != 1537 # skip first row
    puts "get color of product #{i-1} "
    colors = get_cloudinary_color(auth, '/chip/uniqlo' + (i-1).to_s).unshift(i) unless product[1] == '-1'
    colors = [i, -1] if product[1] == '-1'
    writer << colors
  end
end

def get_cloudinary_color(auth, public_id)
  # auth[:public_id] = public_id
  auth[:colors] = true
  colors = []

  result = Cloudinary::Api.resource(public_id, auth)
  result_colors = result['colors']
  result_colors.each_with_index do |rc, i|
    colors.push(rc[0])
    colors.push(rc[1])
    # puts "#{i}, #{rc[0]}, #{rc[1]}"
  end
  colors
end

def call_api(image_url, api_key, api_secret)
  auth = 'Basic ' + Base64.strict_encode64("#{api_key}:#{api_secret}").chomp

  result_arr = Array.new(34)

  response = RestClient.get "https://api.imagga.com/v1/colors?url=#{image_url}", { :Authorization => auth }
  data = JSON.parse(response.body)

  if data["unsuccessful"].size == 0  # size=0 >> success
    info = data["results"][0]["info"]

    # ==== background_colors = result_arr[1~12] ====
    background_colors = info["background_colors"]
    for i in 0..2 do
      unless background_colors[i].nil?  # 有值
        # puts background_colors[i]['html_code']
        # puts background_colors[i]['closest_palette_color_html_code']
        # puts background_colors[i]['closest_palette_color']
        # puts background_colors[i]['percentage']
        result_arr[i*4+1] = background_colors[i]['html_code']                         # i = 1, 5, 9
        result_arr[i*4+2] = background_colors[i]['closest_palette_color_html_code']   # i = 2, 6, 10
        result_arr[i*4+3] = background_colors[i]['closest_palette_color']             # i = 3, 7, 11
        result_arr[i*4+4] = background_colors[i]['percentage']                        # i = 4, 8, 12
      end
    end

    result_arr[13] = info['object_percentage']

    # ==== image_colors = result_arr[14~33] ====
    image_colors = info["image_colors"]
    for i in 0..4 do
      unless image_colors[i].nil?  # 有值
        # puts image_colors[i]['html_code']
        # puts image_colors[i]['closest_palette_color_html_code']
        # puts image_colors[i]['closest_palette_color']
        # puts image_colors[i]['percent']
        result_arr[i*4+14] = image_colors[i]['html_code']                         # i = 14, 18, 22, 26, 30
        result_arr[i*4+15] = image_colors[i]['closest_palette_color_html_code']   # i = 15, 19, 23, 27, 31
        result_arr[i*4+16] = image_colors[i]['closest_palette_color']             # i = 16, 20, 24, 28, 32
        result_arr[i*4+17] = image_colors[i]['percent']                           # i = 17, 21, 25, 29, 33
      end
    end
  else
    puts "fail to call imagga API!"
    puts data["unsuccessful"]
    return nil
  end

  result_arr
  
end


def upload_color_chips
  in_arr = CSV.read("./products0_renamed.txt")

  auth = get_cloudinary_auth

  writer = CSV.open("./color_chip.txt", "wt")
  writer << ["product_id", "cloudinary_url"]
  in_arr.each_with_index do |product, i|
    next if i == 0  # skip first row

    if product[1] != '-1'
      file_name = 'chip/uniqlo' + (i-1).to_s
      str = product[4].split('/')
      color_chip_link = 'http://im.uniqlo.com/images/tw/uq/pc/goods/' + str[-3] + '/chip/' + str[-1].sub!('.jpg', '') + '.gif'
      url = upload_cloudinary(auth, color_chip_link, file_name)
      puts "#{i-1}, #{file_name}"
      puts "uploaded!"
      writer << [i-1, url]
    else
      writer << [i-1, -1]    
    end
    
  end
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

# turn a color hex string to an array of RGB value
def hex2ints(hex)
  # input hex start with hashtag, eg: #ff00ff
  [hex[1, 2].to_i(16), hex[3, 2].to_i(16), hex[5, 2].to_i(16)]
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
keys = ['acc_457c0ba47a89fc7', 'acc_ae57afa9be2771d']
secrets = ['57490716966db483020da088096cfffd', 'cfbe9e0d9dc43d1ce14364beb8c8a62e']

# ok
# get_color
write_color
# upload_color_chips
