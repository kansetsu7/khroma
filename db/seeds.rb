# ===== Gender ==========================
Gender.destroy_all
gender_list = [
  {name: "man"},
  {name: "woman"}
]
gender_list.each do |gender|
  Gender.create(name: gender[:name])
end
puts "Gender created!"


# ===== Category ========================
Category.destroy_all
# man's Category
man_categories = [
  {name: '上衣類'},
  {name: '下身類'}
]
man_categories.each do |man_category|
  Category.create(
    gender_id: 1,
    name: man_category[:name]
  )
end


# ===== woman's Category ================
woman_categories = [
  {name: '上衣類'},
  {name: '下身類'}
]
woman_categories.each do |woman_category|
  Category.create(
    gender_id: 2,
    name: woman_category[:name]
  )
end
puts "Category created!"


# ===== user ===========================
User.create(
  email: "admin@admin.com",
  password: "000000",
  role: "admin"
)
puts "\"Admin\" created!"


# ===== hue_level ===============================
# 目前用RGB系統(適用於光學)，未來會切換到RYB(適用於紡織)
# 
# id, hue(deg), hex,      English name,   Chinese name
# 1,  0,        #FF0000,  Red             紅色
# 2,  30,       #FF8000,  Orange          橘色
# 3,  60,       #FFFF00,  Yellow          黃色
# 4,  90,       #80FF00,  Chartreuse      黃綠色
# 5,  120,      #00FF00,  Green           綠色
# 6,  150,      #00FF80,  Spring Green    春綠色
# 7,  180,      #00FFFF,  Cyan            青色
# 8,  210,      #0080FF,  Azure           湛藍
# 9,  240,      #0000FF,  Blue            藍色
# 10, 270,      #8000FF,  Violet          紫羅蘭色
# 11, 300,      #FF00FF,  Magenta         洋紅
# 12, 330,      #FF0080,  Rose            玫瑰紅
# 13, 0,        -------,  achromatic      無色彩(黑、白、灰)
# color name source: https://zh.wikipedia.org/wiki/%E9%A2%9C%E8%89%B2%E5%88%97%E8%A1%A8

# color_name = ["Red", "Orange", "Yellow", "Chartreuse", "Green", "Spring Green", 
#               "Cyan", "Azure Radiance", "Blue", "Electric Violet", "Magenta", "Rose", "achromatic(black, gray, white)"]
color_name = ["1. 紅色系", "2. 橘色系", "3. 黃色系", "4. 黃綠色系", "5. 綠色系", "6. 春綠色系",
              "7. 青色系", "8. 湛藍色系", "9. 藍色系", "10.紫羅蘭色系", "11. 洋紅色系", "12. 玫瑰紅色系", "13. 無色彩(黑、白、灰)"]
HueLevel.destroy_all
color_name.each_with_index do |name, i|
  HueLevel.create(
    name: color_name[i]
  )
end
puts "have created #{HueLevel.count} hue_levels."


# ===== Principle ===============================
# 
# id, name,       英文名稱
# 1,  同色系,      Monochromatic
# 2,  相近色,      Analogous
# 3,  互補色,      Complementary
# 4,  分離互補,     Split Complementary
# 5,  三角法,      Triad
# 6,  無色彩,      Achromatic
# google sheets : color 內也有


principle_names = ["同色系", "相近色", "互補色", "分離互補", "三角法","無色彩"]
Principle.destroy_all
principle_names.each_with_index do |name, i|
  Principle.create(
    name: principle_names[i],
    image: File.open(File.join(Rails.root, "/public/principle_img/principle#{i+1}.jpeg"))
  )
end
puts "have created #{Principle.count} principles."

# ===== PrincipleColors ===============================
# 詳細內容請看google sheets : color 
PrincipleColor.destroy_all
# ---- 1. Monochromatic ----
for i in 1..13 do
  PrincipleColor.create(
    principle_id: 1,
    hue_level_id: i,
    hue_match1:   i,
  )
end

# ---- 2. Analogous ----
for i in 1..12 do
  h1 = i + 1
  h2 = i - 1
  h1 -= 12 if h1 > 12
  h2 += 12 if h2 < 1
  PrincipleColor.create(
    principle_id: 2,
    hue_level_id: i,
    hue_match1:   h1,
    hue_match2:   h2,
  )
end

# ---- 3. Complementary ----
for i in 1..12 do
  h1 = i + 6
  h1 -= 12 if h1 > 12
  PrincipleColor.create(
    principle_id: 3,
    hue_level_id: i,
    hue_match1:   h1,
  )
end

# ---- 4. Split Complementary ----
for i in 1..12 do
  h1 = i + 5
  h2 = i + 7
  h1 -= 12 if h1 > 12
  h2 -= 12 if h2 > 12
  PrincipleColor.create(
    principle_id: 4,
    hue_level_id: i,
    hue_match1:   h1,
    hue_match2:   h2,
  )
end

# ---- 5. Triad ----
for i in 1..12 do
  h1 = i + 4
  h2 = i + 8
  h1 -= 12 if h1 > 12
  h2 -= 12 if h2 > 12
  PrincipleColor.create(
    principle_id: 5,
    hue_level_id: i,
    hue_match1:   h1,
    hue_match2:   h2,
  )
end

# ---- 6. Achromatic ----
for i in 1..12 do
  PrincipleColor.create(
    principle_id: 6,
    hue_level_id: i,
    hue_match1:   13,
  )
end
