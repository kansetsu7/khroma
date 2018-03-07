namespace :dev do
  task fake_types: :environment do
    Type.destroy_all
    for i in 1..Category.all.count do  #each categories
      for j in 1..3 do  # have 3 types
        Type.create(
          category_id: i,
          name: "#{Category.find(i).gender.name} > #{Category.find(i).name} > type #{j}"
        )
      end
    end
    puts "fake types done!"
  end

  task fake_styles: :environment do
    Style.destroy_all
    for i in 1..Type.all.count do  #each types
      for j in 1..3 do  # have 3 styles
        Style.create(
          type_id: i,
          name: "#{Type.find(i).name} > style #{j}"
        )
      end
    end
    puts "fake styles done!"
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
    50.times do
      Color.create(
        product: Product.all.sample,
        hue_level: HueLevel.all.sample
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