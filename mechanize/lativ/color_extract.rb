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

  call_api(image_url, api_key, api_secret)
end

def call_api(image_url, api_key, api_secret)
  auth = 'Basic ' + Base64.strict_encode64( "#{api_key}:#{api_secret}" ).chomp

  result_arr = Array.new(33)

  response = RestClient.get "https://api.imagga.com/v1/colors?url=#{image_url}", { :Authorization => auth }
  data = JSON.parse(response.body)

  if data["unsuccessful"].size == 0  # size=0 >> success
    puts "success"

    info = data["results"][0]["info"]
    background_colors = info["background_colors"]
    puts "==== background_colors ===="
    background_colors.each_with_index do |color, i|
      puts "// ==== #{i} ===="
      puts "percentage: #{color['percentage']}%"
      puts "rgb: [#{color['r']}, #{color['g']}, #{color['b']}]"
      puts "html_code: #{color['html_code']}"
      puts "closest_palette_color_html_code: #{color['closest_palette_color_html_code']}"
      puts "closest_palette_color: #{color['closest_palette_color']}"      
    end

    puts "==== color_variance & object_percentage ===="
    puts "color_variance: #{info['color_variance']}"
    puts "object_percentage: #{info['object_percentage']}"

    puts "\n==== image_colors ===="
    image_colors = info["image_colors"]
    image_colors.each_with_index do |color, i|
      puts "// ==== #{i} ===="
      puts "percent: #{color['percent']}%"
      puts "rgb: [#{color['r']}, #{color['g']}, #{color['b']}]"
      puts "html_code: #{color['html_code']}"
      puts "closest_palette_color_html_code: #{color['closest_palette_color_html_code']}"
      puts "closest_palette_color: #{color['closest_palette_color']}"
    end
  end
  
end

api_key = ''
api_secret = ''
get_color('https://s3.lativ.com.tw/i/35199/35199011/3519901_500.jpg', api_key, api_secret)
# get_color('https://s3.lativ.com.tw/i/34110/34110111/3411011_500.jpg', api_key, api_secret)