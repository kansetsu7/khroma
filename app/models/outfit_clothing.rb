class OutfitClothing < ApplicationRecord
  belongs_to :outfit
  belongs_to :product, :optional => true  # optional允許不設定
  belongs_to :virtual_product, :optional => true  # optional允許不設定
end
