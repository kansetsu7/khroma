class AddProductIdToColors < ActiveRecord::Migration[5.1]
  def change
    add_column :colors, :product_id, :integer
  end
end
