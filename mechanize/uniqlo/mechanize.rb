require 'mechanize'
require 'watir'
require 'csv'
# gender(男裝) > category(上衣) > type(襯衫) > style(款式) > product
# ===== gender 不用抓，自己設定 =====
$genders_arr = ["men", "women"]
$n_genders = $genders_arr.size

def get_uniqlo_data(category_from_file)
  # get_uniqlo_types(category_from_file)
  get_uniqlo_styles

end

def get_uniqlo_products
  puts "==== get_lativ_products ===="
  styles_arr = read_styles
  # styles[i][j][k][l][0]: name
  # styles[i][j][k][l][1]: link

  products_arr = []
  styles_arr.each_with_index do |gender, i|  # product_arr = [gender0_arr, gender1_arr, ...]
    products_arr.push([])
    gender.each_with_index do |category, j|  # gender0 = [cate0_arr, cate1_arr, ...]
      products_arr[i].push([])  # cate0_arr = [type0_arr, type1_arr, ...]
      category.each_with_index do |type, k|
        products_arr[i][j].push([])  # type0_arr = [style0_arr, style1_arr, ...]
        type.each_with_index do |style, l|
          products_arr[i][j][k].push([])  # style0_arr = []
        end
      end
    end
  end

  product_id = 0
  writer = CSV.open("./products0.txt", "wt")
  writer << ["type_id", "name", "link", "color", "image_link", "gender_id", "category_of_gender_id", "type_of_category_id", "style_of_type_id"]

  products_arr.each_with_index do |gender, i|
    next unless i == 0  # men
    gender.each_with_index do |category, j|
      # next unless j == 0
      puts "======== gender#{i}, category#{j} ========"
      category.each_with_index do |type, k|
        # next unless k == 0
        type.each_with_index do |style, l|
          # next unless l == 1
          puts "category#{j}, type#{k}, style#{l}"
          # puts get_lativ_products_of_style(styles_link_arr[i][j][k][l]) if styles_link_arr[i][j][k][l] == "http://www.lativ.com.tw/Detail/34110011"
          products_arr[i][j][k][l] = get_uniqlo_products_of_style(styles_arr[i][j][k][l])
          products_arr[i][j][k][l].each_with_index do |products, m|
            writer << [product_id, products[0], products[1], products[2]+"-"+products[3], products[4], i, j, k, l]
          end
          product_id += 1
        end
      end      
    end 
  end
  
  write_products(products_arr, 0)
end

def get_uniqlo_products_of_style(style_info)
  # puts "==== get_uniqlo_products_of_style ===="

  # style_info[0]: name
  # style_info[1]: link
  puts ("goto #{style_info[1]}")
  products_arr = []
  page = get_page(style_info[1])
  # puts page.nil?
  main_img = page.search("div#prodImgDefault>img").first['src']
  main_img_name = main_img.split('/').last
  main_img_color = main_img_name[0..1]

  color_pages = page.search("ul#listChipColor>li>div")
  color_pages.each_with_index do |color_page, i|
    # puts "#{i} ====="
    # puts "name: #{style_info[0]}"
    # puts "link: #{style_info[1]}"
    # puts "color: #{color_page['color']}-#{color_page['title']}"
    # puts get_img_link(main_img, main_img_color, color_page['color'])
    products_arr.push([style_info[0], style_info[1], color_page['color'], color_page['title'],
                      get_img_link(main_img, main_img_color, color_page['color'])])
    # products_arr[i][0]: name
    # products_arr[i][1]: link
    # products_arr[i][2]: color code
    # products_arr[i][3]: color name
    # products_arr[i][4]: image link
  end
  products_arr
end

def get_img_link(main_img, main_img_color, target_color)
  return main_img if main_img_color == target_color
  main_img.sub(main_img_color+"_", target_color+"_")
end

def get_uniqlo_styles
  puts "==== get_uniqlo_styles ===="
  types_link_arr = read_type_links

  styles_arr = []
  types_link_arr.each_with_index do |gender, i|  # types_arr = [gender0_arr, gender1_arr, ...]
    styles_arr.push([])
    gender.each_with_index do |category, j|  # gender0 = [cate0_arr, cate1_arr, ...]
      styles_arr[i].push([])  # cate0_arr = [type0_arr, type1_arr, ...]
      category.each_with_index do |type, k|
        styles_arr[i][j].push([])  # type0_arr = []
      end
    end
  end

  styles_arr.each_with_index do |gender, i|
    gender.each_with_index do |category, j|
      puts "get styles for gender#{i}'s category#{j}..."
      category.each_with_index do |type, k|
        puts "goto #{types_link_arr[i][j][k]}"
        styles_of_category_arr = get_uniqlo_styles_of_type(types_link_arr[i][j][k])
        styles_of_category_arr.each_with_index do |style, l|
          style[1].slice!('NT$')  # remove NT$ from price(NT$490 -> 490)
          style[1].sub! ',', ''   # remove comma(1,490 -> 1490)
          styles_arr[i][j][k].push(style)
        end
      end      
    end      
  end

  write_styles(styles_arr)
  
end

def get_uniqlo_styles_of_type(type_link)
  styles_arr = []
  page = get_page(type_link)
  styles = page.search("div.set-alias").search("div.domCreate").search("div.lineupAlias").search("div.blkItemList").search("div.unit")
  styles.each_with_index do |style, i|
    # name, price, link
    style_info = [style.search("dt.name").first.text.strip, style.search("dd.price").first.text.strip,style.search("dd.thumb>a").first['href']]
    styles_arr.push(style_info)
  end
  styles_arr
end

def get_page(style_link)
  
  timeout = 0
  begin
    browser = Watir::Browser.new :safari  # open safari
    browser.goto(style_link)
  rescue Exception => e
    puts "Net::ReadTimeout !!!!!!!!!!!!!!!!!!!!"
    timeout += 1
    if timeout <= 3
      sleep(5)
      retry
    end
  end
  sleep(2)
  page = Nokogiri::HTML.fragment(browser.html)
  browser.close
  system %{ osascript -e 'tell application "Safari" to quit'}  # close safari
  page
end

def get_uniqlo_types(category_from_file)

  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  get_uniqlo_categories unless category_from_file   # category_from_file == false時，會先爬category並存成檔案
  categories_arr = read_needed_categories()         # 實際上需要的categories，從categories.txt找到想要的類別
                                                    # 手動設定needed_categories再讀進來
  # puts_categories(categories_arr)

  types_arr = []
  for i in 0...$n_genders do  # types_arr = [gender0_arr, gender1_arr, ...]
    types_arr.push([])
    for j in 0...categories_arr[i].size do # gender0 = [cate0_arr, cate1_arr, ...]
      types_arr[i].push([])  # cate0_arr = [], 之後爬到資料會變成 [商務襯衫, 休閒襯衫, ...]
    end
  end
  pants_types_arr = [] # uniqlo褲裝types從nav上沒辦法全部爬到，要特別處理
  puts "==== sreaching types ===="
  $genders_arr.each_with_index do |gender, i|
    puts "for #{gender}"
    categories = agent.get("http://www.uniqlo.com/tw/").search("div#gnav_#{gender}").search('div.gnav_inner').search('ul.linkBlock')
    categories.each_with_index do |category_HTML, j|
      types = category_HTML.search('li')
      category_name = ""  #先初始化
      bottom_type_count = 0      # 下身類專用
      types.each_with_index do |type, k|
        type_link = type.search('a')[0].nil? ? nil : type.search('a')[0]['href']
        category_name = type.text if k == 0  # 第一行是category名稱, 後面才是該category所屬types
        next if k == 0
        categories_arr[i].each_with_index do |needed_category, l|
          if needed_category == category_name
            if needed_category == '下身類'  # '下身類' 要特別處理 '所有褲裝' 的問題
              if type.text == '所有褲裝'  # 不管個別褲子type，要再前往'所有褲裝'專屬頁面把褲子的types都爬回來
                pants_types_arr = get_uniqlo_pants_types(type.search('a')[0]['href'])  # 褲子的types
                pants_types_arr.each do |pants_type|
                  types_arr[i][l].push([pants_type, type.search('a')[0]['href']])
                end
              elsif !type.text.include?('褲') || (i == 0 && bottom_type_count == 0) || (i == 1 && bottom_type_count < 3)
                # 不是褲子(是裙子)，要存下來
                # 男裝下身類第一個(牛仔褲)不會出現在'所有褲裝'裡面，要存下來。
                # 女裝下身類前三個不會出現在'所有褲裝'裡面，要存下來。
                types_arr[i][l].push([type.text, type.search('a')[0]['href']])
              end
              bottom_type_count += 1
            else
              # 不是'下身類'
              types_arr[i][l].push([type.text, type.search('a')[0]['href']]) if type.text != '亞麻系列' && type.text != '休閒/連帽'
            end              
          end
        end
      end
    end
  end 

  write_types(types_arr, categories_arr)
end

def get_uniqlo_pants_types(link)
  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  pants_types_arr = []
  types = agent.get(link).search("h3")
  types.each_with_index do |type, i|
    # '更多推薦商品', '合作聯名', '更多商品推薦' 這幾個先不要
    pants_types_arr.push(type.text.strip) unless ['更多推薦商品', '合作聯名', '更多商品推薦'].include?(type.text.strip)
  end
  pants_types_arr
end

def get_uniqlo_categories

  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  categories_arr = []                         # 取代Array.new(size, [])功能
  for i in 0...$n_genders do                  # 因為用上面initialize後再arr[0].push(x)
    categories_arr.push([])                   # 會變成arr[所有] 的值都被設為x
  end                                         #
  
  puts "==== sreaching categories ===="
  $genders_arr.each_with_index do |gender, i|
    puts "for #{gender}"
    categories = agent.get("http://www.uniqlo.com/tw/").search("div#gnav_#{gender}").search('div.gnav_inner').search('ul.linkBlock')
    categories.each_with_index do |category_HTML, j|
      category = category_HTML.search('li').first.text
      categories_arr[i] << category
    end
  end

  # ===== write data in files =====
  write_categories(categories_arr)
end



def write_products(product_arr, gender_id)
  puts "==== writing products#{gender_id}.txt ====" 
  # products_arr[i][0]: name
  # products_arr[i][1]: link
  # products_arr[i][2]: color code
  # products_arr[i][3]: color name
  # products_arr[i][4]: image link
  product_id = 0
  writer = CSV.open("./products#{gender_id}.txt", "wt")
  writer << ["type_id", "name", "link", "color", "image_link", "gender_id", "category_of_gender_id", "type_of_category_id", "style_of_type_id"]
  product_arr.each_with_index do |gender, i|
    gender.each_with_index do |category, j|
      # puts "write styles for gender#{i}'s category#{j}..."
      category.each_with_index do |type, k|
        type.each_with_index do |style, l|
          style.each_with_index do |products, m|
            writer << [product_id, products[0], products[1], products[2]+"-"+products[3], products[4], i, j, k, l]
          end
          product_id += 1
        end
      end      
    end    
  end
end

def write_styles(styles_arr)
  puts "==== writing styles.txt ====" 
  style_id = 0
  writer = CSV.open("./styles.txt", "wt")
  writer << ["type_id", "name", "price", "link", "gender_id", "category_of_gender_id", "type_of_category_id"]
  styles_arr.each_with_index do |gender, i|
    gender.each_with_index do |category, j|
      puts "write styles for gender#{i}'s category#{j}..."
      category.each_with_index do |type, k|
        type.each_with_index do |styles, l|
          writer << [style_id, styles[0], styles[1], styles[2], i, j, k]
        end
        style_id += 1
      end      
    end    
  end
end

def read_styles
  puts "==== READ styles ===="
  types_link_arr = read_type_links

  styles_arr = []
  types_link_arr.each_with_index do |gender, i|  # types_link_arr = [gender0_arr, gender1_arr, ...]
    styles_arr.push([])
    gender.each_with_index do |category, j|  # gender0 = [cate0_arr, cate1_arr, ...]
      styles_arr[i].push([])  # cate0_arr = [type0_arr, type1_arr, ...]
      category.each_with_index do |type, k|
        styles_arr[i][j].push([])  # type0_arr = []
      end
    end
  end

  # in_arr[i] = v
  # v[0]: type_id,
  # v[1]: name,
  # v[2]: price,
  # v[3]: link,
  # v[4]: gender_id,
  # v[5]: category_of_gender_id,
  # v[6]: type_of_category_id,
  # v[7...v.size]: colors

  in_arr = CSV.read("./styles.txt")
  in_arr.each_with_index do |v, i|  
    next if i == 0  # skip first line
    # arr = v[7...v.size].unshift(v[3])
    # arr = arr.unshift(v[1])
    styles_arr[v[4].to_i][v[5].to_i][v[6].to_i].push([v[1], v[3]])
    # puts "#{v[4]}, #{v[5]}, #{v[6]}, #{v[3]}" if i<5
  end
  styles_arr

  # styles_arr[i][j][k][l][0]: name
  # styles_arr[i][j][k][l][1]: link
  # styles_arr[i][j][k][l][2..last]: color
end

def read_type_links
  puts "==== READ types ===="

  categories_arr = read_needed_categories()

  types_arr = []     
  for i in 0...$n_genders do  # types_arr = [gender0_arr, gender1_arr, ...]
    types_arr.push([])
    for j in 0...categories_arr[i].size do # gender0_arr = [cate0_arr, cate1_arr, ...]
      types_arr[i].push([])  
    end
  end

  n_skips = 1
  in_arr = CSV.read("./types.txt")
  in_arr.each_with_index do |v, i|    
    # types_arr[v[3].to_i][v[4].to_i].push([v[1], v[2]]) if i >= n_skips
    types_arr[v[3].to_i][v[4].to_i].push(v[2]) if i >= n_skips
  end

  types_arr

  # # puts arr
  # types_arr.each_with_index do |genders, i|
  #   genders.each_with_index do |categories, j|
  #     categories.each_with_index do |type, k|
  #       puts "#{i}, #{j}, #{k}, #{type}"
  #     end      
  #   end
  # end
end

def read_needed_categories
  puts "==== READ needed_categories ===="
  needed_categories = []               # 取代Array.new(size, [])功能
  for i in 0...$n_genders do            # 因為用上面initialize後再arr[0].push(x)
    needed_categories.push([])         # 會變成arr[所有] 的值都被設為x
  end

  n_skips = 1
  in_arr = CSV.read("./needed_categories.txt")
  in_arr.each_with_index do |arr, i|
    needed_categories[arr[0].to_i].push(arr[1]) if i >= n_skips
  end

  needed_categories.each_with_index do |gender, i|
    puts "gender_id: #{i}"
    gender.each_with_index do |category, j|
      puts category
    end
  end
  needed_categories
end

def write_types(types_arr, categories_arr)
  puts "==== writing types.txt ===="
  category_id = 0
  writer = CSV.open("./types.txt", "wt")
  writer << ["category_id", "name", "link", "gender_id", "category_of_gender_id"]

  types_arr.each_with_index do |genders, i|
    genders.each_with_index do |categories, j|
      categories.each_with_index do |type, k|
        writer << [category_id, type[0], type[1], i, j]
      end
      category_id += 1
    end
  end
end

def puts_types(types_arr, categories_arr)
  puts "==== types ===="
  types_arr.each_with_index do |genders, i|
    puts "- For #{$genders_arr[i]} "
    genders.each_with_index do |categories, j|
      puts "-- #{$genders_arr[i]}'s #{categories_arr[i][j]} "
      categories.each_with_index do |type, k|
        puts "--- #{type}"
      end
    end
  end
end

def write_categories(categories_arr)
  puts "==== writing categories.txt ===="
  writer = CSV.open("./categories.txt", "wt")
  writer << ["gender_id", "name"]
  categories_arr.each_with_index do |genders, i|
    puts "For #{$genders_arr[i]} "
    genders.each_with_index do |category, j|
      writer << [i, category]
    end
  end
  writer.close
end

def puts_categories(categories_arr)
  categories_arr.each_with_index do |genders, i|
    puts "\n###===== #{$genders_arr[i]} =====###"
    genders.each_with_index do |category, j|
      puts "#{j}, #{category}"
    end
  end
end

def write_genders()
  puts "writing genders.txt"
  puts_genders()
  writer = CSV.open("./genders.txt", "wt")
  $genders_arr.each_with_index do |gender, i|
    writer << [i, gender]
    puts "#{i}, #{gender}"
  end    
  writer.close
end

def puts_genders()
  puts "id, name"
  $genders_arr.each_with_index do |gender, i|
    puts "#{i}, #{gender}"
  end
end

# ok!
get_uniqlo_data(true)
