require 'mechanize'
require 'watir'
require 'csv'
# gender(男裝) > category(上衣) > type(襯衫) > style(款式) > product
# ===== gender 不用抓，自己設定 =====
$genders_arr = ["MEN", "WOMEN"]
$n_genders = $genders_arr.size

def get_lativ_data(category_from_file)
  # get_lativ_categories
  # get_lativ_types(true)
  # get_lativ_styles
  get_lativ_products
end

def get_lativ_products
  puts "==== get_lativ_products ===="
  styles_link_arr = read_styles_link

  products_arr = []
  styles_link_arr.each_with_index do |gender, i|  # product_arr = [gender0_arr, gender1_arr, ...]
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
  # ----------------------------------------------------------------
  # puts products_arr[0][0][0][0].class     # is Array
  # puts styles_link_arr[0][0][0][0]        # is string, a link of style
  # ----------------------------------------------------------------

  product_id = 0
  writer = CSV.open("./products0.txt", "a+")
  writer << ["type_id", "name", "image_link", "gender_id", "category_of_gender_id", "type_of_category_id", "style_of_type_id"]

  products_arr.each_with_index do |gender, i|
    gender.each_with_index do |category, j|
      category.each_with_index do |type, k|
        type.each_with_index do |style, l|
          next if skip(i, j, k, l)
          puts "gender#{i}, category#{j}, type#{k}, style#{l}"
          # puts get_lativ_products_of_style(styles_link_arr[i][j][k][l]) if styles_link_arr[i][j][k][l] == "http://www.lativ.com.tw/Detail/34110011"
          products_arr[i][j][k][l] = get_lativ_products_of_style(styles_link_arr[i][j][k][l])
          products_arr[i][j][k][l].each_with_index do |products, m|
            writer << [product_id, products[0], products[1], i, j, k, l]
          end
          product_id += 1
        end
      end      
    end     
  end

  # write_products(products_arr, 0)
end

def skip(i, j, k, l)
  # start at gender1, category0, type0, style85
  start_point = [1,2,1,13]
  return true if i < start_point[0]
  return true if i == start_point[0] && j < start_point[1]
  return true if i == start_point[0] && j == start_point[1] && k < start_point[2]
  return true if i == start_point[0] && j == start_point[1] && k == start_point[2] && l < start_point[3]

  false  # go
end

def get_lativ_products_of_style(style_link)
  # puts "==== get_lativ_products_of_style ===="
  products_arr = []
  page = get_page(style_link)
  colors_page = page.search('div.color').search('a')
  colors_page.each_with_index do |color, i|
    products_arr.push(get_product_attributes('https://www.lativ.com.tw' + color['href']))
  end
  products_arr
end

def get_product_attributes(style_link)
  attributes_arr = []  # name, img_link
  page = get_page(style_link)
  product_name = page.search('span.title1').first
  attributes_arr.push(product_name.text.gsub! product_name.search('span#isize').first.text, '') # full name of product, but not include size 
  attributes_arr.push(page.search('img#productImg').first['src'])
  attributes_arr  # return: [name, img_link]
end

def get_page(style_link)
  puts "goto #{style_link}"
  timeout = 0
  begin
    browser = Watir::Browser.new :safari  # open safari
    browser.goto(style_link)
  rescue Exception => e
    puts "===== Exception #{Time.now.strftime("%d/%m/%Y %H:%M")} ====="
    timeout += 1
    if timeout <= 5
      system %{ osascript -e 'tell application "Safari" to quit'}  # close safari
      sleep(10)
      retry
    end
  end
  # sleep(2)  
  page = Nokogiri::HTML.fragment(browser.html)
  browser.close
  # system %{ osascript -e 'tell application "Safari" to quit'}  # close safari
  page
end
  

def get_lativ_styles
  puts "==== get_lativ_styles ===="
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

  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  styles_arr.each_with_index do |gender, i|
    gender.each_with_index do |category, j|
      puts "get styles for gender#{i}'s category#{j}..."
      category.each_with_index do |type, k|
        # puts "goto #{types_link_arr[i][j][k]}"
        styles_of_category_arr = get_lativ_styles_of_type(types_link_arr[i][j][k])
        styles_of_category_arr.each_with_index do |style, l|
          styles_arr[i][j][k].push(style)
          styles_arr[i][j][k][l][2] = "http://www.lativ.com.tw" + styles_arr[i][j][k][l][2]
        end
        sleep(1) 
      end      
    end      
  end

  # puts "product name: #{styles_arr[0][0][0][0][0]}"
  # puts "price:        #{styles_arr[0][0][0][0][1]}"
  # puts "link:         #{styles_arr[0][0][0][0][2]}"
  write_styles(styles_arr)
end

def get_lativ_styles_of_type(type_link)
  # puts "==== get_lativ_styles_of_type ===="
  styles_arr = []
  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }
  styles = agent.get(type_link).search("li.product-info")
  styles.each_with_index do |style, i|
    # lativ網站style數量會重複，如果同style下有三個product，就會顯示三次style，其中兩個用js掛上display none，所以要過濾重複的
    if i == 0
      duplicated = false
    else
      duplicated = style.search('div.productname')[0].text.strip == styles[i-1].search('div.productname')[0].text.strip
    end

    # name, price, link
    # span的last才抓得到price活動價
    styles_arr.push([style.search('div.productname')[0].text.strip, style.search('span').last.text.strip, style.search('a')[0]['href']]) unless duplicated
  end

  # puts "#{styles_arr.first[0]}, #{styles_arr.first[1]}"
  # puts "#{styles_arr.last[0]}, #{styles_arr.last[1]}"
  styles_arr
end

def get_lativ_types(category_from_file)

  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  get_lativ_categories unless category_from_file   # category_from_file == false時，會先爬category並存成檔案
  categories_arr = read_needed_categories()         # 實際上需要的categories，從categories.txt找到想要的類別
                                                    # 手動設定needed_categories再讀進來
  # puts_categories(categories_arr)

  types_arr = []
  categories_arr.each_with_index do |gender, i|  # types_arr = [gender0_arr, gender1_arr, ...]
    types_arr.push([])
    gender.each_with_index do |category, j|  # gender0 = [cate0_arr, cate1_arr, ...]
      types_arr[i].push([])  # cate0_arr = [], 之後爬到資料會變成 [商務襯衫, 休閒襯衫, ...]
    end
  end

  puts "==== searching types ===="
  $genders_arr.each_with_index do |gender, i|
    puts "for #{gender}"
    genders = agent.get("http://www.lativ.com.tw/#{gender}").search("div#sidenav").search('li.category')   
    genders.each_with_index do |categories, j|
      categories_arr[i].each_with_index do |needed_category, k|
        if needed_category == categories.search("h2").first.text
          puts "need #{needed_category}, got #{categories.search("h2").first.text}"
          types = categories.search("a") 
          types.each do |type|
            types_arr[i][k].push([type.text, "http://www.lativ.com.tw"+type['href']]) unless 'FLEECE 毛圈系列 洋裝'.include?(type.text)  # FLEECE,毛圈系列分類不佳,先不處理. 洋裝太難了也略過
          end   
        end
      end
    end
  end 

  puts_types(types_arr, categories_arr)
  write_types(types_arr, categories_arr)

end

def get_lativ_categories

  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  categories_arr = []                         # 取代Array.new(size, [])功能
  for i in 0...$n_genders do                  # 因為用上面initialize後再arr[0].push(x)
    categories_arr.push([])                   # 會變成arr[所有] 的值都被設為x
  end                                         #
  
  puts "==== searching categories ===="
  $genders_arr.each_with_index do |gender, i|
    puts "for #{gender}"
    categories = agent.get("http://www.lativ.com.tw/#{gender}").search("div#sidenav").search('li.category').search('h2')
    
    categories.each_with_index do |category_HTML, j|
      # puts category_HTML.text
      categories_arr[i] << category_HTML.text
    end
  end

  # ===== write data in files =====
  write_categories(categories_arr)
end

def write_products(product_arr, gender_id)
  puts "==== writing products#{gender_id}.txt ====" 
  product_id = 0
  writer = CSV.open("./products#{gender_id}.txt", "wt")
  writer << ["type_id", "name", "image_link", "gender_id", "category_of_gender_id", "type_of_category_id", "style_of_type_id"]
  product_arr.each_with_index do |gender, i|
    gender.each_with_index do |category, j|
      puts "write styles for gender#{i}'s category#{j}..."
      category.each_with_index do |type, k|
        type.each_with_index do |style, l|
          style.each_with_index do |products, m|
            writer << [product_id, products[0], products[1], i, j, k, l]
          end
          product_id += 1
        end
      end      
    end    
  end
end

def write_tmp_html_file(str)
  writer = File.open("./tmp.html", "wt")
  writer << str
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

def read_styles_link
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

  n_skips = 1
  in_arr = CSV.read("./styles.txt")
  in_arr.each_with_index do |v, i|    
    styles_arr[v[4].to_i][v[5].to_i][v[6].to_i].push(v[3]) if i >= n_skips
    # puts "#{v[4]}, #{v[5]}, #{v[6]}, #{v[3]}" if i<5
  end
  styles_arr
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

  # needed_categories.each_with_index do |gender, i|
  #   puts "gender_id: #{i}"
  #   gender.each_with_index do |category, j|
  #     puts category
  #   end
  # end
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

# page = agent.get("http://www.lativ.com/tw/").links_with(:text => 'WOMEN')[0]

# get_lativ_pants_types("http://www.lativ.com/tw/store/feature/men/bottoms/long-pants/?ref=_navi_1016")


# ok!
get_lativ_data(true)


