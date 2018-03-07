require 'rest_client'
require 'base64'
require 'json'


def get_color(image_url, api_key, api_secret)
  n_skips = 1
  # in_arr = CSV.read("./products0.txt")

  #- 0         , 1   , 2   , 3        , 4                    , 5                  , 6
  #- product_id, name, link, gender_id, category_of_gender_id, type_of_category_id, style_of_type_id

  # in_arr.each_with_index do |product, i|
  #   call_api(image_url, api_key, api_secret)
  # end

  # test_method

  result_arr = call_api(image_url, api_key, api_secret)
  result_arr.each_with_index do |v, i|
    puts "#{i}, #{v}"
  end
end

def test_method
  a =Array.new(3)
  a[1] = nil
  puts a[0]
  puts a[0].nil?
  puts a[1].nil?
end

def call_api(image_url, api_key, api_secret)
  auth = 'Basic ' + Base64.strict_encode64( "#{api_key}:#{api_secret}" ).chomp

  result_arr = Array.new(33)

  response = RestClient.get "https://api.imagga.com/v1/colors?url=#{image_url}", { :Authorization => auth }
  data = JSON.parse(response.body)

  if data["unsuccessful"].size == 0  # size=0 >> success
    puts "success"

    info = data["results"][0]["info"]

    # ==== background_colors = result_arr[0~11] ====
    background_colors = info["background_colors"]
    for i in 0..2 do
      unless background_colors[i].nil?  # 有值
        result_arr[i*4]   = background_colors[i]['html_code']
        result_arr[i*4+1] = background_colors[i]['closest_palette_color_html_code']
        result_arr[i*4+2] = background_colors[i]['closest_palette_color']
        result_arr[i*4+3] = background_colors[i]['percentage']
      end
    end

    # background_colors.each_with_index do |color, i|
    #   puts "// ==== #{i} ===="
    #   puts "percentage: #{color['percentage']}%"
    #   puts "rgb: [#{color['r']}, #{color['g']}, #{color['b']}]"
    #   puts "html_code: #{color['html_code']}"
    #   puts "closest_palette_color_html_code: #{color['closest_palette_color_html_code']}"
    #   puts "closest_palette_color: #{color['closest_palette_color']}"      
    # end

    result_arr[12] = info['object_percentage']

    # puts "==== color_variance & object_percentage ===="
    # puts "color_variance: #{info['color_variance']}"
    # puts "object_percentage: #{info['object_percentage']}"

    # ==== image_colors = result_arr[13~32] ====
    image_colors = info["image_colors"]
    for i in 0..4 do
      unless image_colors[i].nil?  # 有值
        # puts image_colors[i]['html_code']
        # puts image_colors[i]['closest_palette_color_html_code']
        # puts image_colors[i]['closest_palette_color']
        # puts image_colors[i]['percent']
        result_arr[i*4+13] = image_colors[i]['html_code']
        result_arr[i*4+14] = image_colors[i]['closest_palette_color_html_code']
        result_arr[i*4+15] = image_colors[i]['closest_palette_color']
        result_arr[i*4+16] = image_colors[i]['percent']
      end
    end
    
    # image_colors.each_with_index do |color, i|
    #   puts "// ==== #{i} ===="
    #   puts "percent: #{color['percent']}%"
    #   puts "rgb: [#{color['r']}, #{color['g']}, #{color['b']}]"
    #   puts "html_code: #{color['html_code']}"
    #   puts "closest_palette_color_html_code: #{color['closest_palette_color_html_code']}"
    #   puts "closest_palette_color: #{color['closest_palette_color']}"
    # end
    result_arr
  end
  
end

api_key = ''
api_secret = ''
get_color('https://s3.lativ.com.tw/i/35199/35199011/3519901_500.jpg', api_key, api_secret)
# get_color('https://s3.lativ.com.tw/i/34110/34110111/3411011_500.jpg', api_key, api_secret)