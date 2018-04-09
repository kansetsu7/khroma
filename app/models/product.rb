class Product < ApplicationRecord
  has_one :color
  belongs_to :style
  delegate :category, :to => :style
  accepts_nested_attributes_for :color
  validates_presence_of :name, :brand, :image, :link, :style_id, :price, :color_chip
  validates_numericality_of :price
end
