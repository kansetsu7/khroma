module Admin::ProductsHelper

  def show_product_attribute(value)
    return value unless value.is_a? String
    if value.include?('jpg')
      return image_tag(value, :class => "table-product-img")  
    elsif value.include?('http')
      return link_to(value, value, target: :_blank)
    end
    
    value
  end

end
