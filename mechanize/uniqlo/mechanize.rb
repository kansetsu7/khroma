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

def get_uniqlo_styles
  puts "get_uniqlo_styles"
  types_link_arr = read_type_links

  styles_arr = []     
  for i in 0...$n_genders do  # styles_arr = [gender0_arr, gender1arr, ...]
    styles_arr.push([])
    for j in 0...types_link_arr[i].size do # gender_arr = [cate0_arr, cate1_arr, ...]
      styles_arr[i].push([])
      for k in 0...types_link_arr[i][j].size do  # cate0_arr = [type0_arr, type1_arr, ...]
        styles_arr[i][j].push([])  # type0_arr = [] 之後爬到資料會變成[style1, style2]
      end
    end
  end

  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  # read styles from file
  types_link_arr.each_with_index do |categories, i|
    categories.each_with_index do |types, j|
      types.each_with_index do |type_link|
        puts "#{i}, #{j}, #{k}, #{type_link}" 
      end      
    end    
  end
  
end

def get_uniqlo_styles_of_one_category
  page = get_page("http://www.uniqlo.com/tw/store/feature/men/tops/casual-shirts-long/?ref=_navi_1016")
  styles = page.search("div.set-alias")
  File.open("./uniqlo.txt", 'w') { |file| file.write(styles) }

  # .search("div.domCreate").search("div.lineupAlias").search("div.blkItemList").search("div.unit")
  
  # styles.each_with_index do |style, i|
  #   puts style.text
  # end
end

def get_page(style_link)
  browser = Watir::Browser.new :safari  # open safari
  browser.goto(style_link)
  # puts browser.cookies[:my_session]
  sleep(5)
  page = Nokogiri::HTML.fragment(browser.html)
  # version = browser.execute_script('return jQuery.fn.jquery')
  browser.close
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
      types.each_with_index do |type, k|
        type_link = type.search('a')[0].nil? ? nil : type.search('a')[0]['href']
        # puts "#{i}, #{j}, #{k}, #{type.text}, #{type_link}" 
        if k == 0
          category_name = type.text  # 第一行是category名稱, 後面才是該category所屬types
        else
          categories_arr[i].each_with_index do |needed_category, l|
            if needed_category == category_name
              # puts "need #{needed_category}, got #{category_name}"
              if needed_category == '下身類'  # '下身類' 要特別處理 '所有褲裝' 的問題
                if type.text == '所有褲裝'  # 不管個別褲子type，要再前往'所有褲裝'專屬頁面把褲子的types都爬回來
                  pants_types_arr = get_uniqlo_pants_types(type.search('a')[0]['href'])  # 褲子的types
                  pants_types_arr.each do |pants_type|
                    types_arr[i][l].push([pants_type, type.search('a')[0]['href']])
                  end
                elsif !type.text.include?('褲')  # 不是褲子，要存下來
                  types_arr[i][l].push([type.text, type.search('a')[0]['href']])
                end
              else
                types_arr[i][l].push([type.text, type.search('a')[0]['href']])  
              end              
              # puts "--- #{types_arr[i][l]}"
            end
          end
          
        end

      end
    end
  end 

  # puts_types(types_arr, categories_arr)
  write_types(types_arr, categories_arr)  # 先輸出褲子只是'所有褲裝'的types, 後面再處理

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

  pants_types_arr.each_with_index do |type, i|
    puts "#{i}, #{type}"    
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

# page = agent.get("http://www.uniqlo.com/tw/").links_with(:text => 'WOMEN')[0]

# get_uniqlo_pants_types("http://www.uniqlo.com/tw/store/feature/men/bottoms/long-pants/?ref=_navi_1016")

get_uniqlo_styles_of_one_category

# ok!
# get_uniqlo_data(true)



