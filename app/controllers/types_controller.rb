class TypesController < ApplicationController

  def index
    @category = Category.find(params[:category_id])
    @types = @category.types
  end

end
