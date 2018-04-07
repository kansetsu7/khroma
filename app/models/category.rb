class Category < ApplicationRecord
  has_many :types
  belongs_to :gender
  has_many :styles, through: :types
  has_many :products, through: :styles


  def id_with_name
    "#{id}. #{name}"
  end

end
