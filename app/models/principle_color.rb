class PrincipleColor < ApplicationRecord
  belongs_to :principle
  belongs_to :hue_level
  belongs_to :match1_hue_level, class_name: "HueLevel", foreign_key: "hue_match1"
  belongs_to :match2_hue_level, class_name: "HueLevel", foreign_key: "hue_match2", :optional => true  # optional允許hue_match2不設定
  has_many   :outfit_principle_colors
end
