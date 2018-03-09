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
color_name = ["1. 紅色", "2. 橘色", "3. 黃色", "4. 黃綠色", "5. 綠色", "6. 春綠色",
              "7. 青色", "8. 湛藍", "9. 藍色", "10.紫羅蘭色", "11. 洋紅", "12. 玫瑰紅", "13. 無色彩(黑、白、灰)"]
HueLevel.destroy_all
color_name.each_with_index do |name, i|
  HueLevel.create(
    name: color_name[i]
  )
end
puts "have created #{HueLevel.count} hue_levels."