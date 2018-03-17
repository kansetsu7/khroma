class Admin::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  private

  def check_admin
    unless current_user.admin?
      redirect_to root_path
      flash[:alert] = "You can not pass!!"
    end
  end
end