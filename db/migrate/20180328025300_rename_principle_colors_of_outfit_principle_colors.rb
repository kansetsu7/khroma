class RenamePrincipleColorsOfOutfitPrincipleColors < ActiveRecord::Migration[5.1]
  def change
    rename_column :outfit_principle_colors, :priciple_color_id, :principle_color_id
  end
end
