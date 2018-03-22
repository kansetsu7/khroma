class AddHexToHueLevel < ActiveRecord::Migration[5.1]
  def change
    add_column :hue_levels, :hex, :string
  end
end
