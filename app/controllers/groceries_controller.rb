class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

  def index
    respond_to do |format|
      format.json do
        groceries = @groceries.sort_by(&:created_at).map do |grocery|
          {
            id: grocery.id,
            name: grocery.name,
            description: grocery.description,
            count: grocery.items.count,
            cost: grocery.total.to_money.format,
            finished: grocery.finished?
          }
        end
        render json: { data: groceries }
      end
    end
	end

	def show
	end

	def new
  end

  def create
    if @grocery.save
      current_user.default_group = @user_group unless current_user.default_group
      redirect_to @grocery
    else
      render action: :new
    end
	end

	def edit
	end

	def update
	end

  def finish
    current_items = params[:finish][:current_ids].split(",").flat_map{ |id| Item.find(id) }
    next_items = params[:finish][:next_ids].split(",").flat_map{ |id| Item.find(id) }

    @grocery.items = current_items
    @grocery.finished_at = DateTime.now

    new_grocery = Grocery.new(
      name: params[:finish][:name],
      description: params[:finish][:description]
    )
    new_grocery.items = next_items
    new_grocery.user_group = @grocery.user_group

    if @grocery.save && new_grocery.save
      redirect_to new_grocery, notice: "Your new grocery list is setup and ready to use."
    else
      render @grocery, notice: "There was a problem creating your new grocery list."
    end
  end

  def email_group
    @grocery.user_group.users.each do |user|
      UserMailer.send_grocery_list_email(user, @grocery).deliver!
    end

    redirect_to @grocery, notice: 'All kit members have been emailed the grocery list.'
  end

  def recipes
    ingredients = URI.escape(@grocery.items.map(&:name).join(","))
    res = Nokogiri::HTML(open("http://food2fork.com/api/search?key=#{ENV["FOOD2FORK_KEY"]}&q=#{ingredients}"))
    render json: JSON.parse(res)
  end

private

  def grocery_params
    params.require(:grocery).permit(:name, :description)
  end
end
