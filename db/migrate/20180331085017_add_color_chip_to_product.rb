class AddColorChipToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :color_chip, :string
  end
end
