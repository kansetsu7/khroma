class Color < ApplicationRecord
  belongs_to :product
  belongs_to :hue_level  
end
