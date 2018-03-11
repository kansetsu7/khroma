class CreatePrincipleColors < ActiveRecord::Migration[5.1]
  def change
    create_table :principle_colors do |t|
      t.integer :principle_id
      t.integer :hue_level_id
      t.integer :hue_match1
      t.integer :hue_match2, default: -1

      t.timestamps
    end
  end
end
