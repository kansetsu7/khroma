class CreateColors < ActiveRecord::Migration[5.1]
  def change
    create_table :colors do |t|
      t.integer :hue_level_id
      
      t.timestamps
    end
  end
end
