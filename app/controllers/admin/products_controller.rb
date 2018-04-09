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
    @chip_url = @product.color_chip
    @chip_colors = result['colors']
    @chip_colors.each_with_index do |cc, i|
      clothes_color = ClothesColor.new(cc[0])
      cc.push(clothes_color)
      @target_index = i if cc[0] == @product.color.hex
    end
    @hue_levels = HueLevel.all
  end

  def update
    puts color_params.inspect
    @product = Product.find(params[:id])
    @product.update(product_params)
    @product.save

    @color = Color.where('product_id = ?', params[:id]).first
    @color.update(color_params)
    @color.save

    redirect_to admin_style_products_path
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to admin_style_products_path
  end

  def get_chip_colors
    color_chip_url = params[:color_chip_url]
    public_id = 'chip/' + color_chip_url.split('/').last.split('.').first

    begin
      result = Cloudinary::Api.resource(public_id, :colors => true)
      @chip_url = color_chip_url
    rescue Cloudinary::Api::NotFound
      upload_response = Cloudinary::Uploader.upload(color_chip_url, :folder => 'chip')
      @chip_url = upload_response['url']
      result = Cloudinary::Api.resource(upload_response['public_id'], :colors => true)
    end

    @chip_colors = result['colors']
    @chip_colors.each_with_index do |cc, i|
      clothes_color = ClothesColor.new(cc[0])
      cc.push(clothes_color)
    end
    @hue_levels = HueLevel.all
    
    render json: {
      colorInfoHtml: render_to_string(partial: 'shared/color_info', locals: {chip_url: @chip_url, chip_colors: @chip_colors, target_index: 0,
        hue_levels: @hue_levels})
    }

  end

  private
  def product_params
    params.require(:product).permit(:name, :image, :link, :price, :brand, :color_chip)
  end

  def color_params
    {'hue_level_id' => params[:color_select].split('.').first, 'hex' => params[:colorRadios]}
  end
  
end
