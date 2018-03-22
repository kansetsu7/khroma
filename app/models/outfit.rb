class Outfit < ApplicationRecord
  belongs_to :celebrity
  has_many :outfit_principle_colors
end
