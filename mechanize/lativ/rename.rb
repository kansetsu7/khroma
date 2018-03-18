require 'csv'

# tell a string is alphabet/number or not
# return true if is alphabet/number
def alnum?(str)
  str =~ /[[:alnum:]]/
end

# tell a string is Chinese words or not
# return true if is
def han?(str)
  str =~ /\p{Han}/
end

def rename(in_arr, writer, is_product)
  writer << ["type_id", "name", "price", "link", "gender_id", "category_of_gender_id", "type_of_category_id"] unless is_product
  writer << ['style_id','name','link','gender_id','category_of_gender_id','type_of_category_id','style_of_type_id'] if is_product

  gender_col = is_product ? 3 : 4

  in_arr.each_with_index do |data, i|
    next if i == 0
    if data[1] == '-1'
      name_arr = [-1]
      skip = true
    else
      name_arr = data[gender_col] == '0' ? data[1].split('-男') : data[1].split('-女')
      skip = false
    end
    loop do
      skip = true if skip || han?(name_arr[0][-1]) == 0
      unless skip
        name_arr[0] = name_arr[0][0...-1] if alnum?(name_arr[0][-1]) == 0
        if name_arr[0][-1] == '-'
          name_arr[0] = name_arr[0][0...-1]
          skip = true
        end
      end
      break if skip
    end
    # name_arr[0] += name_arr[1] unless name_arr[1].nil?
    writer << [data[0], name_arr[0], data[2], data[3], data[4], data[5], data[6]]
  end
end

file_name = "styles0"
in_arr = CSV.read("./" + file_name + ".txt")
writer = CSV.open("./" + file_name + "_renamed.txt", "wt")
rename(in_arr, writer, false)
