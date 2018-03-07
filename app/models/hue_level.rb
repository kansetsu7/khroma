class HueLevel < ApplicationRecord
  has_many :colors

  has_many :products, through: :colors
end
