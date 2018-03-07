class AddPriceToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :price, :float
  end
end
