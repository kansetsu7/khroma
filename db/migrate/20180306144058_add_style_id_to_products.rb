class AddStyleIdToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :style_id, :integer
  end
end
