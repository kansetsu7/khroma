class CategoriesController < ApplicationController

  def index
    gender = Gender.find(params[:gender_id])
    @categories = gender.categories
  end

end
