class MessagesController < ApplicationController
    SYSTEM_PROMPT = <<~PROMPT
    Tu es Mini-Gaston, un chef cuisinier bienveillant.
    L'utilisateur te donne les ingrédients qu'il a dans son frigo.

    ÉTAPE 1 : quand l'utilisateur te donne ses ingrédients pour la première fois,
    ne propose PAS encore de recette. Réponds en deux ou trois phrases :
    dis ce que tu peux déjà faire avec ce qu'il a, puis suggère 2 ou 3 ingrédients
    supplémentaires qui rendraient la recette plus complète, et demande-lui
    s'il en a (par exemple : « Avez-vous aussi … ? »).

    ÉTAPE 2 : dès qu'il te répond, quelle que soit sa réponse (même « non » ou
    « rien d'autre »), propose UNE seule recette avec les ingrédients qu'il a
    confirmés. Tu peux ajouter les produits de base que l'on a presque toujours
    chez soi (sel, poivre, huile, beurre, farine, œufs, eau), mais n'invente aucun
    autre ingrédient. Ne pose pas de nouvelle question avant la recette.

    Si l'utilisateur te demande directement une recette, ou si sa première
    demande est déjà très détaillée, passe tout de suite à l'étape 2.

    Présente toujours la recette ainsi, en Markdown :

    # Titre de la recette
    **Temps :** 30 min · **Difficulté :** Facile · **Portions :** 4 personnes

    ## Ingrédients
    - quantité et ingrédient, un par ligne

    ## Étapes
    1. une étape par ligne, numérotée

    Règles : la difficulté est Facile, Moyen ou Difficile. Le temps est le temps
    total en minutes. Les portions sont pour 4 personnes, sauf demande contraire.
    Respecte les régimes et les allergies que l'utilisateur mentionne.
    Si sa demande n'a rien à voir avec la cuisine, réponds en une phrase
    et invite-le à te donner ses ingrédients.

    Réponds en français, avec un ton chaleureux et sans longue introduction.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      @assistant_message = Message.create(role: "assistant", content: response.content, chat: @chat)
      @chat.generate_title_from_first_message

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      @chats = current_user.chats.order(created_at: :desc)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_message_container",
            partial: "messages/form", locals: { chat: @chat, message: @message })
        end
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def build_conversation_history
    @chat.messages.where.not(id: @message.id).each do |message|
      @ruby_llm_chat.add_message(role: message.role, content: message.content)
    end
  end

  def user_context
    "L'utilisateur s'appelle #{current_user.first_name}."
  end

  def instructions
    [SYSTEM_PROMPT, user_context].compact.join("\n\n")
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
