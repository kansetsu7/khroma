class AddUserAttributes < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :name, :string, default: "NoName User"
    add_column :users, :avatar, :string
  end
end
