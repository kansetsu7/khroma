class UsersController < ApplicationController

  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])

    @user.update(user_params)


    @user.save
    redirect_to edit_user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :avatar, :password, :password_confirmation)
  end

end
