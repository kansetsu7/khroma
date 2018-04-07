class Admin::ProductsController < Admin::AdminController

  def index
    @style = Style.find(params[:style_id])
    @products = @style.products
    @product = Product.new

  end

  def create
    @product = Product.new(product_params)
    @product.style_id = params[:style_id]
    @product.save
    redirect_to admin_style_products_path
  end

  def edit
    @product = Product.find(params[:id])
    @style = Style.find(params[:style_id])
    public_id = 'chip/'+@product.color_chip.split('/').last.split('.').first
    result = Cloudinary::Api.resource(public_id, :colors => true)
    puts "#{public_id}"
    puts result.inspect
    @chip_colors = result['colors']
    @chip_colors.each_with_index do |cc, i|
      clothes_color = ClothesColor.new(cc[0])
      cc.push(clothes_color)
      # puts "#{i}, #{rc[0]}, #{rc[1]}"
    end
  end

  def update
    @product = Product.find(params[:id])
    @product.update(product_params)
    @product.save
    redirect_to admin_style_products_path
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_style_products_path
  end

  private
  def product_params
    params.require(:product).permit(:name, :image, :link, :price, :brand)
  end
  
end
