class Type < ApplicationRecord
  has_many :styles
  belongs_to :category
end
