class Category < ApplicationRecord
  has_many :types
  belongs_to :gender
  has_many :recommends
  has_many :recommend_products, through: :recommends , source: :product
end
