class Gender < ApplicationRecord
  has_many :categories
  has_many :types, through: :categories
  has_many :styles, through: :types
  has_many :products, through: :styles
  has_many :celebrities
  has_many :outfits, through: :celebrities

  def id_with_name
    "#{id}. #{name}"
  end
end
