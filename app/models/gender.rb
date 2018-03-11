class Gender < ApplicationRecord
  has_many :categories
  has_many :types, through: :categories
  has_many :styles, through: :types
  has_many :products, through: :styles
end
