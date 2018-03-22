class Celebrity < ApplicationRecord
  belongs_to :gender
  has_many :outfits
end
