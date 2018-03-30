class AddDefaultToPrincipleColors < ActiveRecord::Migration[5.1]
  def change
    change_column_default :principle_colors, :hue_option2, -1
  end
end
