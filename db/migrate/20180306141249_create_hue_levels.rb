class CreateHueLevels < ActiveRecord::Migration[5.1]
  def change
    create_table :hue_levels do |t|
      t.string :name 
      t.timestamps
    end
  end
end
