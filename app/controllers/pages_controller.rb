
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    @recipes = visible_recipes
  end

  def dashboard
    @recipes = current_user.recipes
  end

  private

  def visible_recipes
    if user_signed_in?
      current_user.recipes
    else
      User.find_by!(email: "guest@minigaston.example").recipes
    end
  end
end
