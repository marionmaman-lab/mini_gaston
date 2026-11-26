
class RecipesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_recipe, only: %i[show]

  def index
    @recipes = visible_recipes
  end

  def show
  end

  private

  def visible_recipes
    if user_signed_in?
      current_user.recipes
    else
      guest_user.recipes
    end
  end

  def guest_user
    User.find_by!(email: "guest@minigaston.example")
  end

  def set_recipe
    @recipe = visible_recipes.find(params[:id])
  end
end
