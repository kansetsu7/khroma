class Product < ApplicationRecord
  has_one :color
  belongs_to :style
end