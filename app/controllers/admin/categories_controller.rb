class Admin::CategoriesController < ApplicationController

  def index
    if params[:gender_id].present?
      @categories = Category.where(gender_id: params[:gender_id])
    else
      @categories = Category.all
    end
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
