class CreateStyles < ActiveRecord::Migration[5.1]
  def change
    create_table :styles do |t|
      t.string :name
      t.integer :type_id
      t.timestamps
    end
  end
end
