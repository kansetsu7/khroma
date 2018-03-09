class Type < ApplicationRecord
  has_many :styles
  belongs_to :category

  has_many :products, through: :styles

  has_many :recommends
  has_many :recommend_products, through: :recommends , source: :product
end
