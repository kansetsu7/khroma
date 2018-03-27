class Color < ApplicationRecord
  belongs_to :product, :optional => true  # optional允許不設定
  belongs_to :hue_level  
  belongs_to :virtual_product, :optional => true  # optional允許不設定
end
