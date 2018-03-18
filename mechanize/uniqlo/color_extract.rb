require 'rest_client'
require 'base64'
require 'json'
require 'csv'

def write_color
  in_arr = CSV.read("./color.txt")
  writer = CSV.open("./clothes_color.txt", "wt")
  writer <<['product_id', 'color in hex', 'color name', 'percentage of clothes', 'hue_level']
  arr_hlv = Array.new(13, 0)
  # remove first color in image color
  less = 0
  clothes_percentage = 75.0  # 衣服佔圖片面積(預估)
  in_arr.each_with_index do |color, i| 
    next if i == 0  # skip first row 
    pic_main_percentage = color[17].to_f      # 圖片主色佔圖片面積比
    clothes_main_percentage = color[21].to_f  # 衣服主色佔衣服面積比

    # 如果主要顏色佔圖片面積 > 衣服佔圖片的主要面積，代表衣服主要色＝圖片主要色＝color[15]
    # 如果不是，代表衣服主要顏色＝圖片次要色＝color[19]
    if pic_main_percentage >= clothes_percentage  
      clothes_color = color[15]
      name_id = 16
      clothes_main_percentage = clothes_percentage / pic_main_percentage * 100
    else
      clothes_color = color[19]
      name_id = 20
      # 如果顏色接近，則將佔色比相加
      for j in 1..3 do
        clothes_main_percentage += color[21+4*j].to_f if color[19] == color[19+4*j]
      end
      clothes_main_percentage = clothes_main_percentage/(100.0 - pic_main_percentage) * 100
    end
    hlv = get_hue_level(clothes_color)
    arr_hlv[hlv-1] += 1 
    writer << [i, clothes_color, color[name_id], clothes_main_percentage.to_i, hlv]
  end

  arr_hlv.each_with_index do |n, i|
    puts "#{i+1}: #{n}"
  end
end

def get_color(keys, secrets)
  n_skips = 1
  in_arr = CSV.read("./products0.txt")

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
  # puts in_arr[0][2]
  n_auth = keys.count
  used_auth = 0
  img_count = 0

  writer = CSV.open("./color.txt", "wt")
  writer << ["product_id", "color"]
  in_arr.each_with_index do |product, i|
    next if i == 0  # skip first row  
    puts "get color of product #{i} "
    api_key = keys[used_auth]
    api_secret = secrets[used_auth]
    result_arr = call_api(product[4], api_key, api_secret)
    img_count += 1
    used_auth = img_count / 1996
    unless result_arr.nil?
      result_arr[0] = i
      writer << result_arr
    end   
  end

end

def test_method
  in_arr = CSV.read("./products0.txt")
  puts CSV.close?
  CSV.close
  puts CSV.close?
end

def call_api(image_url, api_key, api_secret)
  auth = 'Basic ' + Base64.strict_encode64( "#{api_key}:#{api_secret}" ).chomp

  result_arr = Array.new(34)

  response = RestClient.get "https://api.imagga.com/v1/colors?url=#{image_url}", { :Authorization => auth }
  data = JSON.parse(response.body)

  if data["unsuccessful"].size == 0  # size=0 >> success
    info = data["results"][0]["info"]

    # ==== background_colors = result_arr[1~12] ====
    background_colors = info["background_colors"]
    puts '----------- background_colors ------------'
    for i in 0..2 do
      unless background_colors[i].nil?  # 有值
        puts background_colors[i]['html_code']
        puts background_colors[i]['closest_palette_color_html_code']
        puts background_colors[i]['closest_palette_color']
        puts background_colors[i]['percentage']
        # result_arr[i*4+1] = background_colors[i]['html_code']                         # i = 1, 5, 9
        # result_arr[i*4+2] = background_colors[i]['closest_palette_color_html_code']   # i = 2, 6, 10
        # result_arr[i*4+3] = background_colors[i]['closest_palette_color']             # i = 3, 7, 11
        # result_arr[i*4+4] = background_colors[i]['percentage']                        # i = 4, 8, 12
      end
    end

    result_arr[13] = info['object_percentage']

    # ==== image_colors = result_arr[14~33] ====
    image_colors = info["image_colors"]
    puts '----------- image_colors ------------'
    for i in 0..4 do
      unless image_colors[i].nil?  # 有值
        puts image_colors[i]['html_code']
        puts image_colors[i]['closest_palette_color_html_code']
        puts image_colors[i]['closest_palette_color']
        puts image_colors[i]['percent']
        # result_arr[i*4+14] = image_colors[i]['html_code']                         # i = 14, 18, 22, 26, 30
        # result_arr[i*4+15] = image_colors[i]['closest_palette_color_html_code']   # i = 15, 19, 23, 27, 31
        # result_arr[i*4+16] = image_colors[i]['closest_palette_color']             # i = 16, 20, 24, 28, 32
        # result_arr[i*4+17] = image_colors[i]['percent']                           # i = 17, 21, 25, 29, 33
      end
    end

    # ==== foreground_colors = result_arr[] ====
    foreground_colors = info["foreground_colors"]
    puts '----------- foreground_colors ------------'
    for i in 0..2 do
      unless foreground_colors[i].nil?  # 有值
        puts foreground_colors[i]['html_code']
        puts foreground_colors[i]['closest_palette_color_html_code']
        puts foreground_colors[i]['closest_palette_color']
        puts foreground_colors[i]['percentage']
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

class Color

  attr_reader :r, :g, :b, :h, :s, :l, :v, :hsv

  def initialize(hex)
    @r = hex[1, 2].to_i(16)
    @g = hex[3, 2].to_i(16)
    @b = hex[5, 2].to_i(16)

    ri = @r / 255.0
    gi = @g / 255.0
    bi = @b / 255.0

    cmax = [ri, gi, bi].max
    cmin = [ri, gi, bi].min
    delta = cmax - cmin

    @l = (cmax + cmin) / 2.0

    if delta == 0
      @h = 0
    elsif cmax == ri
      @h = 60 * (((gi - bi) / delta) % 6)
    elsif cmax == gi
      @h = 60 * (((bi - ri)/ delta) + 2)
    elsif cmax == bi
      @h = 60 * (((ri - gi)/ delta) + 4)
    end

    if (delta == 0)
      @s = 0
    else
      @s = delta / ( 1 - (2*@l -1).abs )
    end

    @h = @h.round(2)
    @s = (@s * 100).round(2)
    @l = (@l * 100).round(2)

    # HSV Calculation
    # Hue calculation
    if delta == 0
      @hsv = [0]
    elsif cmax == ri
      @hsv = [60 * (((gi - bi) / delta) % 6)]
    elsif cmax == gi
      @hsv = [60 * (((bi - ri)/ delta) + 2)]
    elsif cmax == bi
      @hsv = [60 * (((ri - gi)/ delta) + 4)]
    end

    # Saturation calculation
    if (cmax == 0)
      @hsv  << 0
    else
      @hsv << delta / cmax
    end

    # Value calculation
    @hsv << cmax
    @v = (cmax * 100).round(2)

    @hsv = [@hsv[0].round(2), (@hsv[1] * 100).round(2), (@hsv[2] * 100).round(2)]
  end

  def to_s
    "red=#{r} green=#{g} blue=#{b} hue=#{h} saturation=#{s} lightness=#{l}"
  end

  def to_hex
    "##{r.to_s(16).rjust(2, '0')}#{g.to_s(16).rjust(2, '0')}#{b.to_s(16).rjust(2, '0')}"
  end

  def distance(color)
    [(self.h - color.h) % 360, (color.h - self.h) % 360].min
  end

  def extract_rgb(color_hash)
    color_hash = color_hash[0..6]
    color_hash = color_hash[1..6] if color_hash[0] == '#'
    r = color_hash[0..1].to_i(16)
    g = color_hash[2..3].to_i(16)
    b = color_hash[4..5].to_i(16)
    [r, g, b]
  end

end

# turn a color hex string to an array of RGB value
def hex2ints(hex)
  # input hex start with hashtag, eg: #ff00ff
  [hex[1, 2].to_i(16), hex[3, 2].to_i(16), hex[5, 2].to_i(16)]
end

def get_hue_level(color_hex)
  c = Color.new(color_hex)
  # ---- achromatic 無色彩 ----
  # v1 = 23.0  # lativ藏青的v=23.1
  # v2 = 80.0
  # s1 = 10.0  # 5
  # s2 = 3.0
  # a = (100 - v2) / (s2 - s1)
  # b = 100 - (s2 * a)
  # return 13 if c.hsv[2] <= v1
  # return 13 if (c.hsv[2] > v1 && c.hsv[2] < v2) && c.hsv[1] < s1
  # return 13 if (c.hsv[2] >= v2 && c.hsv[2] <= 100) && c.hsv[1] <= (c.hsv[2] - b) / a
  
  v1 = 23  # lativ藏青的v=23.1
  v2 = 13  # v1
  s1 = 30
  s2 = 3
  a = (100 - v2) / (s2 - s1)
  b = 100 - (s2 * a)
  return 13 if c.hsv[2] <= v1
  return 13 if (c.hsv[2] >= v1 && c.hsv[2] <= 100) && c.hsv[1] <= (c.hsv[2] - b) / a

  # ---- chromatic ----
  # hue_level,  hue range
  # 1,          hue < 15 || hue >= 345
  # 2,          15 <= hue < 45
  # 3,          45 <= hue < 75
  # ...
  # 11,         285 <= hue < 315
  # 12,         315 <= hue < 345
  for hue_level in 2..12 do
    return hue_level if c.hsv[0] >= 15 + 30 * (hue_level - 2) && c.hsv[0] < 45 + 30 * (hue_level - 2)
  end

  return 1
end
keys = ['acc_6f5fce3fad9df94', 'acc_7316f4629599694']
secrets = ['edfb1419aa52c50e4c6d99bedccd2f1d', '12139ad6ab21eb8c917bf8e780af88f7']

# ok
# get_color(keys, secrets)
# write_color
api_key = 'acc_457c0ba47a89fc7'
api_secret = '57490716966db483020da088096cfffd'
call_api('http://im.uniqlo.com/images/tw/uq/pc/goods/406602/chip/67_406602.gif', api_key, api_secret)