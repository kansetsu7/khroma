class Principle < ApplicationRecord
  mount_uploader :image, PrincipleImgUploader
  has_many :principle_colors
end
