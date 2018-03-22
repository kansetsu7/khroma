class CreateVirtualProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :virtual_products do |t|
      t.integer :category_id
      t.timestamps
    end
  end
end
