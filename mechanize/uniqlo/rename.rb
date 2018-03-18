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
  writer << ['style_id','name','link', "color", "img_link",'gender_id','category_of_gender_id','type_of_category_id','style_of_type_id'] if is_product

  gender_col = is_product ? 5 : 4
  in_arr.each_with_index do |data, i|
    next if i == 0
    data[1].sub! '男裝 ', '' if data[gender_col] == '0'
    data[1].sub! '男裝', '' if data[gender_col] == '0'
    data[1].sub! '女裝 ', '' if data[gender_col] == '1'
    data[1].sub! '女裝', '' if data[gender_col] == '1'
    writer << in_arr[i]
  end
end

file_name = "products0"
in_arr = CSV.read("./" + file_name + ".txt")
writer = CSV.open("./" + file_name + "_renamed.txt", "wt")
rename(in_arr, writer, true)
