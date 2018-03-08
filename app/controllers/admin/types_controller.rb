class Admin::TypesController < ApplicationController

  def index
    @types = Type.all
    @type = Type.new
    @categories = Category.all
  end

  def create
    @type = Type.new(type_params)
    @type.save
    redirect_to admin_types_path
  end

  def edit
    @type = Type.find(params[:id])
    @categories = Category.all
  end

  def update
    @type = Type.find(params[:id])
    @type.update(type_params)
    @type.save
    redirect_to admin_types_path
  end

  def destroy
    @type = Type.find(params[:id])
    @type.destroy
    redirect_to admin_types_path
  end

  private
  def type_params
    params.require(:type).permit(:name, :category_id)
  end
  
end
