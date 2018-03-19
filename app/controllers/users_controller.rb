class UsersController < ApplicationController

  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:notice] = "Profile has been successfully updated"   
    else
      flash[:alert] = "Profile was failed to update. #{@user.errors.full_messages.to_sentence}"
    end  
    redirect_back(fallback_location: root_path)
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :avatar, :password, :password_confirmation)
  end

end
