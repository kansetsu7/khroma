class Admin::CategoriesController < ApplicationController

  def index
    @categories = Category.all
    @category = Category.new
    @genders = Gender.all
  end

  def create
    @category = Category.new(category_params)
    @category.save
    redirect_to admin_categories_path
  end

  def edit
    @category = Category.find(params[:id])
    @genders = Gender.all
  end

  def update
    @category = Category.find(params[:id])
    @category.update(category_params)
    @category.save
    redirect_to admin_categories_path
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to admin_categories_path
  end

  private
  def category_params
    params.require(:category).permit(:name, :gender_id)
  end


end
