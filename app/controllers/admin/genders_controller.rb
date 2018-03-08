class Admin::GendersController < ApplicationController

  def index
    @genders = Gender.all
    @gender = Gender.new
  end

  def create
    @gender = Gender.new(gender_params)
    @gender.save
    redirect_to admin_genders_path
  end

  def edit
    @gender = Gender.find(params[:id])
  end

  def update
    @gender = Gender.find(params[:id])
    @gender.update(gender_params)
    @gender.save
    redirect_to admin_genders_path
  end

  def destroy
    @gender = Gender.find(params[:id])
    @gender.destroy
    redirect_to admin_genders_path
  end

  private
  def gender_params
    params.require(:gender).permit(:name)
  end

end
