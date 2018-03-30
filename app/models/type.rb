class Type < ApplicationRecord
  has_many :styles
  belongs_to :category

  has_many :products, through: :styles

  delegate :gender, :to => :category
end
