namespace :dev do
  task fake_types: :environment do
    puts "== Start fake_types..."
    Type.destroy_all
    in_arr = CSV.read(Rails.root.to_s + "/mechanize/types.txt")
    in_arr.each_with_index do |type, i|
      next if i == 0  # skip first line, it's just header
      # type[0] = category_id (start at 0)
      # type[1] = khroma_type_id (start at 0)
      # type[2] = name
      Type.create!(
        category_id: type[0].to_i + 1,
        name: type[2]
      )     
    end
    puts "Have created #{Type.count} fake types!"
    puts
  end

  task fake_styles: :environment do
    puts "== Start fake_styles..."
    Style.destroy_all

    lativ_style_names  = CSV.read(Rails.root.to_s+"/mechanize/lativ/styles0_renamed.txt")
    uniqlo_style_names = CSV.read(Rails.root.to_s+"/mechanize/uniqlo/styles0_renamed.txt")

    lativ_types_ref  = CSV.read(Rails.root.to_s + "/mechanize/lativ_types.txt")
    uniqlo_types_ref = CSV.read(Rails.root.to_s + "/mechanize/uniqlo_types.txt")

    lativ_style_names.each_with_index do |style, i|
      next if i == 0  # skip first row
      # puts "row#{i+1}, style[0]=#{style[0]}, type_id: #{lativ_types_ref[style[0].to_i+1][1].to_i + 1}"
      Style.create!(
        type_id: lativ_types_ref[style[0].to_i + 1][1].to_i + 1,
        name: style[1]
      )
    end

    puts "- lativ styles created!"

    uniqlo_style_names.each_with_index do |style, i|
      next if i == 0  # skip first row
      # puts "row#{i+1}, style[0]=#{style[0]}, type_id: #{uniqlo_types_ref[style[0].to_i+1][1].to_i + 1}"
      Style.create!(
        type_id: uniqlo_types_ref[style[0].to_i + 1][1].to_i + 1,
        name: style[1]
      )
    end
    puts "- uniqlo styles created!"

    puts "Have created #{Style.count} fake styles!"
    puts
  end

  task fake_products: :environment do
    puts "== Start fake_products..."

    def get_lativ_product_link(style_link, product_img_link)
      style_link.sub! style_link.split('/').last, product_img_link.split('/')[5]
    end

    lativ_products  = CSV.read(Rails.root.to_s+"/mechanize/lativ/products0_renamed.txt")
    uniqlo_products = CSV.read(Rails.root.to_s+"/mechanize/uniqlo/products0_renamed.txt")

    lativ_styles  = CSV.read(Rails.root.to_s+"/mechanize/lativ/styles0_renamed.txt")
    uniqlo_styles = CSV.read(Rails.root.to_s+"/mechanize/uniqlo/styles0_renamed.txt")
    lativ_style_count = lativ_styles.count - 1

    Product.destroy_all

    # lativ products ------
    lativ_products.each_with_index do |product, i|
      next if i == 0  # skip first row
      if product[1] == '-1'  # sold out products
        Product.create!(
          style_id: product[0].to_i + 1,
          name: '',
          brand: '',
          image: '',
          link: '',
          price: -1,
        )
      else
        Product.create!(
          style_id: product[0].to_i + 1,
          name: product[1],
          brand: 'lativ',
          image: product[2],
          link: get_lativ_product_link(lativ_styles[product[0].to_i+1][3], product[2]),
          price: lativ_styles[product[0].to_i+1][2],
        )
      end   
    end
    puts "- lativ products created!"

    # uniqlo products ------
    uniqlo_products.each_with_index do |product, i|
      next if i == 0  # skip first row
      Product.create!(
        style_id: product[0].to_i + lativ_style_count + 1,
        name: product[1],
        brand: 'uniqlo',
        image: product[4],
        link: product[2],
        price: uniqlo_styles[product[0].to_i+1][2],
      )
    end
    puts "- uniqlo products created!"

    puts "Have created #{Product.count} fake products!"
    puts
  end

  task fake_colors: :environment do
    puts "== Start fake_colors..."  

    lativ_colors  = CSV.read(Rails.root.to_s+"/mechanize/lativ/clothes_color.txt")
    uniqlo_colors = CSV.read(Rails.root.to_s+"/mechanize/uniqlo/clothes_color.txt")
    # _colors[i][0] = product_id
    # _colors[i][1] = color in hex (RGB)
    # _colors[i][2] = color name
    # _colors[i][3] = percentage of clothes
    # _colors[i][4] = hue_level

    lativ_products_count = lativ_colors.count - 1
    Color.destroy_all

    # lativ products ------
    lativ_colors.each_with_index do |color, i|
      next if i == 0  # skip first row
      unless color[1] == '-1'  # not a sold out products
        Color.create!(
          product: Product.find(i),
          hue_level_id: color.last,
          hex: color[1]
        )
      end
    end
    puts "- lativ products created!"


    # uniqlo products ------
    uniqlo_colors.each_with_index do |color, i|
      next if i == 0  # skip first row
      unless color[1] == '-1'  # not a sold out products
        Color.create!(
          product: Product.find(i + lativ_products_count),
          hue_level_id: color.last,
          hex: color[1]
        )
      end
    end
    puts "- uniqlo products created!"

    puts "Have created #{Color.count} colors!"
    puts
  end

  task remove_useless_data: :environment do
    puts "== Removing useless data..."
    counter = 0
    # destroy sold out products -----
    @products = Product.where(price: -1)
    counter = @products.count
    @products.destroy_all
    puts "- #{counter} useless products removed!"

    # destroy styles that don't have any prdoucts -----
    @styles = Style.all
    counter = 0
    @styles.each_with_index do |style, i|
      next unless style.products.count == 0
      style.destroy
      counter += 1
    end
    puts "- #{counter} useless style products removed!"

    # destroy types that don't have any prdoucts -----
    @types = Type.all
    counter = 0
    @types.each_with_index do |type, i|
      next unless type.products.count == 0
      type.destroy
      counter += 1
    end
    puts "- #{counter} useless type products removed!"

    puts "All useless data have been removed!"
    puts
  end

  task test: :environment do
    p = Product.first
    puts p.color.hue_level.id
  end

  task fake_all: :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
    Rake::Task['dev:fake_types'].execute
    Rake::Task['dev:fake_styles'].execute
    Rake::Task['dev:fake_products'].execute
    Rake::Task['dev:fake_colors'].execute
    Rake::Task['dev:remove_useless_data'].execute
  end
end