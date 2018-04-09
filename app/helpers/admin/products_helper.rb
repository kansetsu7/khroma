module Admin::ProductsHelper

  def show_product_attribute(value)
    return value unless value.is_a? String
    if value.include?('http')
      return is_image?(value) ? image_tag(value, :class => "table-product-img") : link_to(value, value, target: :_blank)
    end
    value
  end

  private
  def is_image?(url)
    url = URI.parse(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")

    http.start do |http|
      return http.head(url.request_uri)['Content-Type'].start_with? 'image'
    end
  end

end
