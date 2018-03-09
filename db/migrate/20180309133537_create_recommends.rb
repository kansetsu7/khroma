class CreateRecommends < ActiveRecord::Migration[5.1]
  def change
    create_table :recommends do |t|

      t.integer :product_id
      t.integer :gender_id
      t.integer :category_id
      t.integer :type_id

      t.timestamps
    end
  end
end
