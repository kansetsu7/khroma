module KhromaHelper
  def show_optional1_colors(optional_colors)

    return nil if optional_colors[0].nil?
    color_name = optional_colors[0].name.split(' ')[1]
    color_name += optional_colors[1].nil? ? '' : (' 或 ' + optional_colors[1].name.split(' ')[1])

    ("<div>對此配色法則，您還可以選擇 " + color_name + " 作為其他服飾配件顏色來搭配</div>").html_safe   
  end
end
