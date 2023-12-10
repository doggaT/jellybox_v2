class UsersController < ApplicationController
  @users = User.all

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    attributes = %i[username email password]
    devise_parameter_sanitizer.permit(:edit_profile, keys: attributes)
  end

  before_action :authenticate_user!
  def index
    @user = User.find(params[:id])
    redirect_to root_path unless @user == current_user
  end

  def show
    @user = User.find(params[:id])
  end

  def edit_profile
    @user = User.find(params[:id])
  end

  def delete
    @user = User.find(params[:id])
  end
end
