class Admin::StylesController < ApplicationController

  def index
    if params[:type_id].present?
      @styles = Style.where(type_id: params[:type_id])
    else
      @styles = Style.all
    end
    @style = Style.new
    @types = Type.all
  end

  def create
    @style = Style.new(style_params)
    @style.save
    redirect_to admin_styles_path
  end

  def edit
    @style = Style.find(params[:id])
    @types = Type.all
  end

  def update
    @style = Style.find(params[:id])
    @style.update(style_params)
    @style.save
    redirect_to admin_styles_path
  end

  def destroy
    @style = Style.find(params[:id])
    @style.destroy
    redirect_to admin_styles_path
  end

  private
  def style_params
    params.require(:style).permit(:name, :type_id)
  end
  
end
