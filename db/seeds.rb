# Gender
Gender.destroy_all
gender_list = [
  {name: "man"},
  {name: "woman"}
]
gender_list.each do |gender|
  Gender.create(name: gender[:name])
end
puts "Gender created!"

# Category
Category.destroy_all
# man's Category
man_categories = [
  {name: 'top'},
  {name: 'bottom'}
]
man_categories.each do |man_category|
  Category.create(
    gender_id: 1,
    name: man_category[:name]
  )
end

# woman's Category
woman_categories = [
  {name: 'top'},
  {name: 'bottom'}
]
woman_categories.each do |woman_category|
  Category.create(
    gender_id: 2,
    name: woman_category[:name]
  )
end
puts "Category created!"

# user
User.create(
  email: "admin@admin.com",
  password: "000000",
  role: "admin"
)
puts "\"Admin\" created!"