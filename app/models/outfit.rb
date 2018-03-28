class Outfit < ApplicationRecord
  belongs_to :celebrity
  has_many :outfit_principle_colors
  has_many :outfit_clothings
  has_many :products, through: :outfit_clothings
  has_many :virtual_products, through: :outfit_clothings
  has_many :product_colors, through: :products, foreign_key: :product_id, source: :color
  has_many :virtual_product_colors, through: :virtual_products, foreign_key: :virtual_product_id, source: :color
end
