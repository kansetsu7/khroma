class AddImageToImageColors < ActiveRecord::Migration[5.1]
  def change
    add_column :principle_colors, :image, :string
    remove_column :principles, :image
  end
end
