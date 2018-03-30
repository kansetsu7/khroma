class Product < ApplicationRecord
  has_one :color
  belongs_to :style
  delegate :category, :to => :style
end
