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
    Product.destroy_all
    for i in 1..Style.all.count do  #each Styles
      for j in 1..3 do  # have 3 Products
        Product.create(
          style_id: i,
          name: "#{Style.find(i).name} > product #{j}"
        )
      end
    end
    puts "fake products done!"
  end

  task test: :environment do
    Style.destroy_all
    in_arr = CSV.read(Rails.root.to_s+"/mechanize/lativ/styles.txt")
    # puts in_arr[0]
    # puts in_arr[1].last.to_i
    in_arr.each_with_index do |style, i|
      if in_arr[i][4] == '0'  # read men only
        Style.create(
          type_id: in_arr[i].last.to_i,
          name: "#{Type.find(i).name} > style #{j}"
        )
      end      
    end
  end

  task fake_all: :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
    # Rake::Task['dev:test'].execute
    Rake::Task['dev:fake_types'].execute
    Rake::Task['dev:fake_styles'].execute
    # Rake::Task['dev:fake_products'].execute
  end
end