class ClothesColor

  attr_reader :rgy_r, :ryb_y, :ryb_b, :h, :s, :v, :hue_level, :not_achromatic_hue_level

  def initialize(rgb_hex)
    @rgb_r = rgb_hex[1, 2].to_i(16)
    @rgb_g = rgb_hex[3, 2].to_i(16)
    @rgb_b = rgb_hex[5, 2].to_i(16)

    # hsv = self.to_ryb_base_hsv
    hsv = self.to_rgb_base_hsv
    @h = hsv[0]
    @s = round_down(hsv[1], 100)
    @v = round_down(hsv[2], 100)

    @hue_level = get_hue_level(false)
    @not_achromatic_hue_level = get_hue_level(true)
  end

  def to_rgb_base_hsv
    ri = @rgb_r / 255.0
    gi = @rgb_g / 255.0
    bi = @rgb_b / 255.0

    cmax = [ri, gi, bi].max
    cmin = [ri, gi, bi].min
    delta = cmax - cmin

    # HSV Calculation
    # Hue calculation
    if delta == 0
      h = 0
    elsif cmax == ri
      h = 60 * (((gi - bi) / delta) % 6)
    elsif cmax == gi
      h = 60 * (((bi - ri)/ delta) + 2)
    elsif cmax == bi
      h = 60 * (((ri - gi)/ delta) + 4)
    end

    # Saturation calculation
    if (cmax == 0)
      s = 0
    else
      s = delta / cmax * 100
    end

    # Value calculation
    v = cmax * 100
    [kuler_hue(h), s, v]    
  end

  # Distributed under the MIT License from the Open Source Initiative (OSI) - 
  # http://www.opensource.org/licenses/mit-license.php
  # 
  # mapping RGB hue to adobe kuler's color wheel's hue
  # 
  # source: https://github.com/benknight/kuler-d3/blob/master/colorwheel.js
  #         function: scientificToArtisticSmooth
  # UI http://benknight.github.io/kuler-d3/

  def kuler_hue(in_hue)    

    return in_hue * (60.0 / 35.0) if in_hue < 35.0
    return mapRange(in_hue, 35.0,  60.0,  60.0,  122.0) if in_hue < 60.0
    return mapRange(in_hue, 60.0,  120.0, 122.0, 165.0) if in_hue < 120.0
    return mapRange(in_hue, 120.0, 180.0, 165.0, 218.0) if in_hue < 180.0
    return mapRange(in_hue, 180.0, 240.0, 218.0, 275.0) if in_hue < 240.0
    return mapRange(in_hue, 240.0, 300.0, 275.0, 330.0) if in_hue < 300.0
           mapRange(in_hue, 300.0, 360.0, 330.0, 360.0)
  end

  def mapRange(value, fromLower, fromUpper, toLower, toUpper)
    (toLower + (value - fromLower) * ((toUpper - toLower) / (fromUpper - fromLower)))
  end

  def round_down(num, nk)
    (num * nk).round.to_f / nk
  end

  def is_achromatic?
    s < 7 || v <= 20 ? true : false
  end

  def get_hue_level(skip_achromatic)
    # ---- achromatic 無色彩 ----
    
    # uniqlo's white is more grayish than lativ
    # OFF-White #E0DFCE v=8.04
    unless skip_achromatic
      puts "skip_achromatic #{skip_achromatic}"
      return 13 if self.s < 8.1 && self.v >= 80  # white
      return 14 if self.s < 7 && self.v < 80 && self.v > 20 # gray
      return 15 if self.v <= 20  # black
    end    

    # ---- chromatic ----
    # hue_level,  hue range
    # 1,          hue < 15 || hue >= 345
    # 2,          15 <= hue < 45
    # 3,          45 <= hue < 75
    # ...
    # 11,         285 <= hue < 315
    # 12,         315 <= hue < 345
    for hue_level in 2..12 do
      return hue_level if self.h >= 15 + 30 * (hue_level - 2) && self.h < 45 + 30 * (hue_level - 2)
    end

    return 1
  end
end