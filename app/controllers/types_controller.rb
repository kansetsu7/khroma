class TypesController < ApplicationController

  def index
    @types = Type.where(category_id: params[:category_id])
  end

end
