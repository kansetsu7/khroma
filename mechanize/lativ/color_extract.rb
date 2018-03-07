require 'rest_client'
require 'base64'
require 'json'
require 'csv'

def read_color
  in_arr = CSV.read("./color.txt")
  # puts in_arr.last.first
  # puts in_arr.last.last.nil?
end

def get_color(api_key, api_secret)
  n_skips = 1
  in_arr = CSV.read("./products0.txt")

  # -------content of in_arr -----------
  # in_arr[0] = type_id
  # in_arr[1] = name
  # in_arr[2] = image_link
  # in_arr[3] = gender_id
  # in_arr[4] = category_of_gender_id
  # in_arr[5] = type_of_category_id
  # in_arr[6] = style_of_type_id
  # ------------------------------------
  
  # puts in_arr[0][2]

  writer = CSV.open("./color2.txt", "wt")
  writer << ["product_id", "color"]
  in_arr.each_with_index do |product, i|
    if i > 1999  # skip first row
      puts "get color of product #{i} "
      result_arr = call_api(product[2], api_key, api_secret)
      unless result_arr.nil?
        result_arr[0] = i
        writer << result_arr
      end      
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
    for i in 0..2 do
      unless background_colors[i].nil?  # 有值
        result_arr[i*4+1] = background_colors[i]['html_code']                       # i = 1, 5, 9
        result_arr[i*4+2] = background_colors[i]['closest_palette_color_html_code']   # i = 2, 6, 10
        result_arr[i*4+3] = background_colors[i]['closest_palette_color']             # i = 3, 7, 11
        result_arr[i*4+4] = background_colors[i]['percentage']                        # i = 4, 8, 12
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

    result_arr[13] = info['object_percentage']

    # puts "==== color_variance & object_percentage ===="
    # puts "color_variance: #{info['color_variance']}"
    # puts "object_percentage: #{info['object_percentage']}"

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
    
    # image_colors.each_with_index do |color, i|
    #   puts "// ==== #{i} ===="
    #   puts "percent: #{color['percent']}%"
    #   puts "rgb: [#{color['r']}, #{color['g']}, #{color['b']}]"
    #   puts "html_code: #{color['html_code']}"
    #   puts "closest_palette_color_html_code: #{color['closest_palette_color_html_code']}"
    #   puts "closest_palette_color: #{color['closest_palette_color']}"
    # end
  else
    puts "fail to call imagga API!"
    puts data["unsuccessful"]
    return nil
  end

  result_arr
  
end

api_key = ''
api_secret = ''
get_color(api_key, api_secret)