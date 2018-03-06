class AddIndexToStylesAndProducts < ActiveRecord::Migration[5.1]
  def change
    add_index :styles, :type_id, name:"IDX_styles_type"
    add_index :products, :style_id, name:"IDX_products_style"
  end
end
