class OutfitClothing < ApplicationRecord
  belongs_to :outfit
  belongs_to :product
  belongs_to :virtual_product
end
