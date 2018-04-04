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

    lativ_color_chips  = CSV.read(Rails.root.to_s+"/mechanize/lativ/color_chip.txt")
    uniqlo_color_chips = CSV.read(Rails.root.to_s+"/mechanize/uniqlo/color_chip.txt")

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
          color_chip: ''
        )
      else
        Product.create!(
          style_id: product[0].to_i + 1,
          name: product[1],
          brand: 'lativ',
          image: product[2],
          link: get_lativ_product_link(lativ_styles[product[0].to_i+1][3], product[2]),
          price: lativ_styles[product[0].to_i+1][2],
          color_chip: lativ_color_chips[i][1]
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
        color_chip: uniqlo_color_chips[i][1]
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
    puts "- lativ colors created!"


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
    puts "- uniqlo colors created!"

    puts "Have created #{Color.count} colors!"
    puts
  end

  task fake_outfits: :environment do
    puts "=== Start fake outfits"
    uniqlo_outfits  = CSV.read(Rails.root.to_s+"/mechanize/outfits/outfit_link.txt")
    lativ_products_count = CSV.read(Rails.root.to_s+"/mechanize/lativ/products0_renamed.txt").count - 1

    uniqlo_outfits.each_with_index do |uniqlo_outfit, i|
      next if i == 0
      celebrity_id = uniqlo_outfit[1].split('%2F')[1] == 'men' ? 1 : 2
      Outfit.create!(
        celebrity_id: celebrity_id,
        image: 'http://www.uniqlo.com' + uniqlo_outfit[2]
      )
      # puts "#{i}, #{celebrity_id}, #{uniqlo_outfit[2]}"
    end

    puts "Have created #{Outfit.count} outfits!"
    puts
  end

  task fake_virtual_products: :environment do
    puts "=== Start fake virtual porducts"
    v_products  = CSV.read(Rails.root.to_s+"/mechanize/outfits/outfit_virtual_product.txt")
    # v_products[i][0]: outfit_id,
    # v_products[i][1]: category,
    # v_products[i][2]: link,
    # v_products[i][3]: color_chip_id,
    # v_products[i][4]: cloudinary chip link,
    # v_products[i][5]: RGB hex,
    # v_products[i][6]: hue_level
    
    virtual_product_id = 1
    v_products.each_with_index do |v_product, i|
      next if i == 0 || v_product[4] == '-1'
      VirtualProduct.create!(
        category_id: v_product[1].to_i + 1
      )
      
      Color.create!(
        virtual_product_id: virtual_product_id,
        hue_level_id: v_product[6].to_i,
        hex: v_product[5]
      )
      
      OutfitClothing.create!(
        outfit_id: v_product[0].to_i + 1,
        virtual_product_id: virtual_product_id
      )
      # puts '-------'
      # puts "virtual_product_id: #{virtual_product_id}, category_id: #{v_product[1].to_i + 1}"
      # puts "hue_level_id: #{v_product[6]}, hex: #{v_product[5]}"
      # puts "outfit_id: #{v_product[0].to_i + 1}"

      virtual_product_id += 1
    end

    puts "Have created #{VirtualProduct.count} virtual porducts!"
    puts
  end

  task fake_outfit_clothings: :environment do
    puts "=== Start fake outfit clothings"
    lativ_product_count = CSV.read(Rails.root.to_s + "/mechanize/lativ/products0_renamed.txt").count - 1
    outfit_products  = CSV.read(Rails.root.to_s + "/mechanize/outfits/outfit_product.txt")
    outfit_products.each_with_index do |outfit_product, i|
      next if i == 0
      OutfitClothing.create!(
        outfit_id: outfit_product[0].to_i + 1,
        product_id: outfit_product[1].to_i + lativ_product_count + 1
      )
      # puts "outfit_id: #{outfit_product[0].to_i + 1}, product_id: #{outfit_product[1].to_i + lativ_product_count + 1}"
    end

    puts "Have created #{OutfitClothing.count} outfit clothings!"
    puts

    # Remove outfits that don't have any outfit clothings
    puts "=== Remove usless outfits"
    counter = 0
    @outfits = Outfit.all
    @outfits.each do |outfit|
      next unless outfit.outfit_clothings.count <= 1
      outfit.destroy
      counter += 1
    end

    puts "- #{counter} useless outfits removed!"
    puts
  end

  task fake_outfit_principle_colors: :environment do
    # hue_level_id為上身顏色，match1_hue_level為下身顏色
    
    puts "=== Start fake outfit principle colors"
    @outfits = Outfit.all
    @outfits.each_with_index do |outfit, i|
      top_hue_levels = []
      bottom_hue_levels = []
      outfit.products.each do |product|
        product.category.id.odd? ? top_hue_levels.push(product.color.hue_level_id) : bottom_hue_levels.push(product.color.hue_level_id) 
      end
      outfit.virtual_products.each_with_index do |product, j|
        product.category.id.odd? ? top_hue_levels.push(product.color.hue_level_id) : bottom_hue_levels.push(product.color.hue_level_id) 
      end

      top_hue_levels.each do |thlv|
        principle_colors = PrincipleColor.where(hue_level_id: thlv)
        principle_colors.each do |principle_color|
          bottom_hue_levels.each do |bhlv|
            if principle_color.match1_hue_level.id == bhlv
              OutfitPrincipleColor.create!(
                principle_color_id: principle_color.id,
                outfit_id: outfit.id
              )
            end
          end
        end        
      end

      # hue_levels = []
      # outfit.product_colors.each_with_index do |pc, j|
      #   hue_levels.push(pc.hue_level.id)
      # end
      # outfit.virtual_product_colors.each_with_index do |vpc, j|
      #   hue_levels.push(vpc.hue_level.id)
      # end

      # hue_levels.each_with_index do |hue_level, j|
      #   principle_colors = PrincipleColor.where(hue_level_id: hue_level)
      #   principle_colors.each do |principle_color|
      #     for k in (j + 1)...hue_levels.count
      #       match1_hue_level = principle_color.match1_hue_level.id
      #       if match1_hue_level == hue_levels[k]
      #         OutfitPrincipleColor.create!(
      #           principle_color_id: principle_color.id,
      #           outfit_id: outfit.id
      #         )
      #       end
      #     end
      #   end
      # end
    end 

    puts "Have created #{OutfitPrincipleColor.count} outfit principle colors!"
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
    puts "- #{counter} useless style removed!"

    # destroy types that don't have any prdoucts -----
    @types = Type.all
    counter = 0
    @types.each_with_index do |type, i|
      next unless type.products.count == 0
      type.destroy
      counter += 1
    end
    puts "- #{counter} useless type removed!"
    
    # Remove outfits that don't have any outfit principle colors -----
    counter = 0
    @outfits = Outfit.all
    @outfits.each do |outfit|
      next unless outfit.outfit_principle_colors.count == 0
      outfit.destroy
      counter += 1
    end

    puts "- #{counter} useless outfits removed!"
    puts

    puts "All useless data have been removed!"
    puts
  end

  task test: :environment do
    outfit = Outfit.find(455)
    outfit.products.each_with_index do |product, i|
      puts "product #{product.id}, category #{product.category.name}, hlv #{product.color.hue_level_id} #{product.color.hex}"
    end
    outfit.virtual_products.each_with_index do |product, i|
      puts "virtual_product #{product.id}, category #{product.category.name}, hlv #{product.color.hue_level_id} #{product.color.hex}"
    end


  end

  task fake_all: :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
    Rake::Task['dev:fake_types'].execute
    Rake::Task['dev:fake_styles'].execute
    Rake::Task['dev:fake_products'].execute
    Rake::Task['dev:fake_colors'].execute
    Rake::Task['dev:fake_outfits'].execute
    Rake::Task['dev:fake_virtual_products'].execute
    Rake::Task['dev:fake_outfit_clothings'].execute
    Rake::Task['dev:fake_outfit_principle_colors'].execute
    Rake::Task['dev:remove_useless_data'].execute
    # Rake::Task['dev:test'].execute
  end
end