class Outfit < ApplicationRecord
  belongs_to :celebrity
  has_many :outfit_principle_colors
  has_many :outfit_clothings
  has_many :products, through: :outfit_clothings
  has_many :virtual_products, through: :outfit_clothings
end
