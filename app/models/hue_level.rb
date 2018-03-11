class HueLevel < ApplicationRecord
  has_many :colors

  has_many :products, through: :colors
  has_many :principle_colors
end
