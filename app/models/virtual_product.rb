class VirtualProduct < ApplicationRecord
  has_many :outfit_clothings
  belongs_to :category
end
