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
  {name: '上衣類'},  # id = 1
  {name: '下身類'}   # id = 2
]
man_categories.each do |man_category|
  Category.create(
    gender_id: 1,
    name: man_category[:name]
  )
end


# ===== woman's Category ================
woman_categories = [
  {name: '上衣類'},  # id = 3
  {name: '下身類'}   # id = 4
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
# 目前用RYB系統
# 
# id, hue in RYB(deg),  hex(RGB), 
# 1,  0,                #FF0000,  
# 2,  30,               #FF8000,  
# 3,  60,               #FFFF00,  
# 4,  90,               #80FF00,  
# 5,  120,              #00FF00,  
# 6,  150,              #00FF80,  
# 7,  180,              #00FFFF,  
# 8,  210,              #0080FF,  
# 9,  240,              #0000FF,  
# 10, 270,              #8000FF,  
# 11, 300,              #FF00FF,  
# 12, 330,              #FF0080,  
# 13, 0,                #FFFFFF,  
# 14, 0,                #808080,  
# 15, 0,                #000000,  
# color name source: https://zh.wikipedia.org/wiki/%E9%A2%9C%E8%89%B2%E5%88%97%E8%A1%A8

# color_name = ["Red", "Orange", "Yellow", "Chartreuse", "Green", "Spring Green", 
#               "Cyan", "Azure Radiance", "Blue", "Electric Violet", "Magenta", "Rose", "achromatic(black, gray, white)"]
color_name = ["1. 紅色系", "2. 橘紅色系", "3. 橘色系", "4. 橘黃色系", "5. 黃色系", "6. 黃綠色系",
              "7. 綠色系", "8. 藍綠色系", "9. 藍色系", "10. 藍紫色系", "11. 紫色系", "12. 紫紅色系",
              "13. 無色彩(白)", "14. 無色彩(灰)", "15. 無色彩(黑)"]
# hex = ['#FF0000', '#FF5500', '#FF7F00', '#FFA900', '#FFFF00', '#7FFF00',
#        '#00FF00', '#00FFFD', '#0000FF', '#8000FF', '#FF00FF', '#FF0080', '#000000']
hex = ['#FF0000', '#FF4000', '#FF8000', '#FFBF00', '#FFFF00', '#81D41A',
       '#00A933', '#158466', '#2A6099', '#55308D', '#800080', '#BF0041',
       '#FFFFFF', '#808080', '#000000']
HueLevel.destroy_all
color_name.each_with_index do |name, i|
  HueLevel.create(
    name: color_name[i],
    hex:  hex[i]
  )
end
puts "Have created #{HueLevel.count} hue_levels."


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
  )
end

puts "Have created #{Principle.count} principles."

# ===== PrincipleColors ===============================
# 詳細內容請看google sheets : color 
PrincipleColor.destroy_all
def create_pinciple_color(principle_id, hue_level_id, hue_match1, file_num, hue_option1 = -1, hue_option2 = -1)
  PrincipleColor.create!(
    principle_id: principle_id,
    hue_level_id: hue_level_id,
    hue_match1:   hue_match1,
    hue_option1:  hue_option1,
    hue_option2:  hue_option2,
    image: File.open(File.join(Rails.root, "/public/principle_color_img/pc#{file_num}.jpg"))
  )
end

# ---- 1. Monochromatic ----
for i in 1..13 do
  create_pinciple_color(1, i, i, i)
end

create_pinciple_color(1, 14, 14, 13)
create_pinciple_color(1, 15, 15, 13)
create_pinciple_color(1, 13, 14, 13)
create_pinciple_color(1, 13, 15, 13)
create_pinciple_color(1, 14, 13, 13)
create_pinciple_color(1, 14, 15, 13)
create_pinciple_color(1, 15, 13, 13)
create_pinciple_color(1, 15, 14, 13)

# ---- 2. Analogous ----
for i in 1..12 do
  h1 = i + 1
  h2 = i + 2
  h3 = i - 1
  h1 -= 12 if h1 > 12
  h2 -= 12 if h2 > 12
  h3 += 12 if h3 < 1
  create_pinciple_color(2, i, h1, 22 + (i - 1) * 4, h2, h3)
  create_pinciple_color(2, i, h2, 23 + (i - 1) * 4, h1)

  h1 = i - 1
  h2 = i - 2
  h3 = i + 1
  h1 += 12 if h1 < 1
  h2 += 12 if h2 < 1
  h3 -= 12 if h3 > 12
  file_num = i == 1 ? 66 : 22 + (i - 2) * 4
  file_num2 = i > 2 ? 23 + (i - 3) * 4 : 59 + 4 * i
  create_pinciple_color(2, i, h1, file_num, h2, h3)
  create_pinciple_color(2, i, h2, file_num2, h1)
end

# ---- 3. Complementary ----
for i in 1..12 do
  h1 = i + 6
  h1 -= 12 if h1 > 12
  create_pinciple_color(3, i, h1, 69 + i)
end

# ---- 4. Split Complementary ----
for i in 1..12 do
  h1 = i + 5
  h2 = i + 7
  h1 -= 12 if h1 > 12
  h2 -= 12 if h2 > 12
  create_pinciple_color(4, i, h1, 80 + i * 2, h2)
  create_pinciple_color(4, i, h2, 80 + i * 2, h1)
end

# ---- 5. Triad ----
for i in 1..12 do
  h1 = i + 4
  h2 = i + 8
  h1 -= 12 if h1 > 12
  h2 -= 12 if h2 > 12
  create_pinciple_color(5, i, h1, 104 + i * 2, h2)
  create_pinciple_color(5, i, h2, 104 + i * 2, h1)
end

# ---- 6. Achromatic ----
for i in 1..12 do
  create_pinciple_color(6, i, 13, 129 + i)
end

for i in 1..12 do
  create_pinciple_color(6, 13, i, 129 + i)
end

for i in 1..12 do
  create_pinciple_color(6, i, 14, 153 + i)
end

for i in 1..12 do
  create_pinciple_color(6, 14, i, 153 + i)
end

for i in 1..12 do
  create_pinciple_color(6, i, 15, 177 + i)
end

for i in 1..12 do
  create_pinciple_color(6, 15, i, 177 + i)
end


puts "Have created #{PrincipleColor.count} principle colors."

# ===== Celebrity ================
Celebrity.create!(
  name: 'Uniqlo 男model',
  gender_id: 1
)

Celebrity.create!(
  name: 'Uniqlo 女model',
  gender_id: 2
)
puts "Have created #{Celebrity.count} celebrities."