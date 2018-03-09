class Gender < ApplicationRecord
  has_many :categories

  has_many :recommends
  has_many :recommend_products, through: :recommends , source: :product

end
