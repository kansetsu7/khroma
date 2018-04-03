class PrincipleColor < ApplicationRecord
  mount_uploader :image, PrincipleColorImageUploader
  belongs_to :principle
  belongs_to :hue_level
  belongs_to :match1_hue_level, class_name: "HueLevel", foreign_key: "hue_match1"
  belongs_to :option1_hue_level, class_name: "HueLevel", foreign_key: "hue_option1", :optional => true  # optional允許hue_match2不設定
  belongs_to :option2_hue_level, class_name: "HueLevel", foreign_key: "hue_option2", :optional => true  # optional允許hue_match2不設定
  has_many   :outfit_principle_colors
  has_many   :outfits, through: :outfit_principle_colors
end
