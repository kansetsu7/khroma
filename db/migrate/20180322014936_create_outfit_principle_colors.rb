class CreateOutfitPrincipleColors < ActiveRecord::Migration[5.1]
  def change
    create_table :outfit_principle_colors do |t|
      t.integer :priciple_color_id
      t.integer :outfit_id
      t.timestamps
    end
  end
end
