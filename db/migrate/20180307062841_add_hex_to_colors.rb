class AddHexToColors < ActiveRecord::Migration[5.1]
  def change
    add_column :colors, :hex, :string
  end
end
