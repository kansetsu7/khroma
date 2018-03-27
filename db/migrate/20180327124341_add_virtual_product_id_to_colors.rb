class AddVirtualProductIdToColors < ActiveRecord::Migration[5.1]
  def change
    add_column :colors, :virtual_product_id, :integer
  end
end
