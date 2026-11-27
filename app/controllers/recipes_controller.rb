
class RecipesController < ApplicationController
  RECIPE_FIELDS = %w[title ingredients steps duration_in_minutes difficulty servings].freeze

  RECIPE_SCHEMA = {
    name: "RecipeSchema",
    schema: {
      type: "object",
      properties: {
        title: { type: "string" },
        ingredients: { type: "string" },
        steps: { type: "string" },
        duration_in_minutes: { type: "integer" },
        difficulty: { type: "string" },
        servings: { type: "integer" }
      },
      required: RECIPE_FIELDS,
      additionalProperties: false
    }
  }

  before_action :authenticate_user!, except: %i[index show]
  before_action :set_recipe, only: %i[show]

  def index
    @recipes = visible_recipes
  end

  def show
  end

  def create
    @chat = current_user.chats.find(params[:chat_id])
    return redirect_to recipe_path(@chat.recipe) if @chat.recipe

    message = @chat.messages.where(role: "assistant").find(params[:message_id])

    response = RubyLLM.chat.with_schema(RECIPE_SCHEMA).ask(
      "Extrais la recette de ce texte. Ingrédients séparés par des virgules, " \
      "étapes numérotées « 1. … », une par ligne. " \
      "La durée est un nombre entier de minutes (1 h 30 = 90).\n\n#{message.content}"
    )
    data = response.content
    data = JSON.parse(data) if data.is_a?(String)

    @recipe = Recipe.new(data.slice(*RECIPE_FIELDS))
    @recipe.user = current_user
    @recipe.chat = @chat

    if @recipe.save
      redirect_to recipe_path(@recipe), notice: "Recette enregistrée !"
    else
      redirect_to chat_path(@chat), alert: "Impossible d'enregistrer la recette."
    end
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
