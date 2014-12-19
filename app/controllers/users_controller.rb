class UsersController < ApplicationController
	skip_before_filter :require_login, only: [:index, :new, :create]
	
	def index
	end

  def show
    @active_grocery = Grocery.last
    @user = User.find(params[:id])
    @items = @user.items - @active_grocery.items
  end

  def new
    @user = User.new
  end

  def create
  	@user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to @user, notice: "Hey Softie #{@user.name}"  
    else  
      render :new
    end
  end

private
	
	def user_params
		params.require(:user).permit(:name, :email, :password, :password_confirmation)
	end 
end
