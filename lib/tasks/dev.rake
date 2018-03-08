namespace :dev do
  task fake_types: :environment do
    puts "start fake_types..."
    Type.destroy_all
    in_arr = CSV.read(Rails.root.to_s+"/mechanize/lativ/types.txt")
    in_arr.each_with_index do |type, i|
      if type[3] == '0'  # read men only, 如果要男女都讀, 記得跳過第一行!
        # ----------------------------------------------------------------------
        # in_arr[i][4] == 2 時，所屬category為bottom, id應為2. 其他為top, id應為1  
        # ----------------------------------------------------------------------    
        category_id = type[4].to_i == 2 ? 2 : 1
        Type.create(
          category_id: category_id,
          name: type[1]
        )
      end      
    end
    puts "#{Type.count} fake types done!"
  end

  task fake_styles: :environment do
    puts "start fake_styles..."
    Style.destroy_all
    in_arr = CSV.read(Rails.root.to_s+"/mechanize/lativ/styles.txt")
    in_arr.each_with_index do |style, i|
      if i > 0
        Style.create(
          type_id: style[0].to_i+1,
          name: style[1]
        )
      end      
    end
    puts "#{Style.count} fake styles done!"
  end

  task fake_products: :environment do
    puts "start fake_products..."  

    def get_product_link(style_link, product_img_link)
      style_link.sub! style_link.split('/').last, product_img_link.split('/')[5]
    end

    Product.destroy_all
    styles_arr = CSV.read(Rails.root.to_s+"/mechanize/lativ/styles.txt")
    in_arr = CSV.read(Rails.root.to_s+"/mechanize/lativ/products0.txt")
    in_arr.each_with_index do |product, i|
      if i > 0
        # puts "#{product[0]}, #{product[1]}, #{product[2]}, price:#{styles_arr[product[0].to_i+1][2]}"
        Product.create(
          style_id: product[0].to_i+1,
          name: product[1],
          brand: 'lativ',
          image: product[2],
          link: get_product_link(styles_arr[product[0].to_i+1][3], product[2]),
          price: styles_arr[product[0].to_i+1][2],
        )
      end      
    end
    puts "fake products done!"
  end

  task fake_hue_levels: :environment do
    HueLevel.destroy_all
    for i in 1..12 do 
      HueLevel.create(
        name: "hue_level #{i}"
      )
    end
    puts "have created #{HueLevel.count} hue_levels."
  end

  task fake_colors: :environment do
    Color.destroy_all
    for i in 1..Product.all.count do
      Color.create(
        product: Product.find(i),
        hue_level: HueLevel.first
      )
    end
    puts "have created #{Color.count} colors"
  end

  task test: :environment do
  end

  task fake_all: :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
    Rake::Task['dev:fake_types'].execute
    Rake::Task['dev:fake_styles'].execute
    Rake::Task['dev:fake_products'].execute
    Rake::Task['dev:fake_hue_levels'].execute
    Rake::Task['dev:fake_colors'].execute
  end
end