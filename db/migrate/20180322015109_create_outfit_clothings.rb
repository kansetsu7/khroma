class CreateOutfitClothings < ActiveRecord::Migration[5.1]
  def change
    create_table :outfit_clothings do |t|
      t.integer :outfit_id
      t.integer :product_id
      t.integer :virtual_product_id
      t.timestamps
    end
  end
end
