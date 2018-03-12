require 'csv'

def alnum?(str)
  str =~ /[[:alnum:]]/
end

def han?(str)
  str =~ /\p{Han}/
end

in_arr = CSV.read("./products0.txt")
writer = CSV.open("./products0-1.txt", "wt")

writer << ['style_id','name','link','gender_id','category_of_gender_id','type_of_category_id','style_of_type_id']

in_arr.each_with_index do |data, i|
  next if i == 0
  name_arr = data[1].split('-男')
  puts "===== #{i} ======="
  skip = false
  loop do
    skip = true if han?(name_arr[0][-1]) == 0
    unless skip
      name_arr[0] = name_arr[0][0...-1] if alnum?(name_arr[0][-1]) == 0
      if name_arr[0][-1] == '-'
        name_arr[0] = name_arr[0][0...-1]
        skip = true
      end
    end
    break if skip
  end
  # puts name_arr[0]+name_arr[1]
  writer << [data[0], name_arr[0]+name_arr[1], data[2], data[3], data[4], data[5], data[6]]
end