class ChatResponseJob < ApplicationJob
  queue_as :default
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
    total : en minutes s'il fait moins d'une heure (45 min), en heures et minutes
    au-delà (1 h 30, 2 h). Les portions sont pour 4 personnes, sauf demande contraire.
    Respecte les régimes et les allergies que l'utilisateur mentionne.
    Si sa demande n'a rien à voir avec la cuisine, réponds en une phrase
    et invite-le à te donner ses ingrédients.
    Réponds en français, avec un ton chaleureux et sans longue introduction.
  PROMPT
  def perform(user_message_id)
    user_message = Message.find(user_message_id)
    chat = user_message.chat
    assistant_message = chat.messages.create!(role: "assistant", content: "")
    llm = RubyLLM.chat
    chat.messages.where("id < ?", user_message.id).order(:id).each do |message|
      llm.add_message(role: message.role, content: message.content)
    end
    content = ""
    last_broadcast = Time.current
    llm.with_instructions(instructions_for(chat.user)).ask(user_message.content) do |chunk|
      next if chunk.content.nil?
      content += chunk.content
      if Time.current - last_broadcast > 0.1
        assistant_message.update!(content: content)
        last_broadcast = Time.current
      end
    end
    assistant_message.update!(content: content)
    chat.generate_title_from_first_message
    if chat.saved_change_to_title?
      Turbo::StreamsChannel.broadcast_update_to chat, target: "chat_title", html: chat.title
    end
  rescue StandardError => e
    Rails.logger.error("ChatResponseJob : #{e.message}")
    assistant_message&.update(content: "Désolé, je n'ai pas pu répondre. Réessayez dans un instant.")
  end
  private
  def instructions_for(user)
    [SYSTEM_PROMPT, "L'utilisateur s'appelle #{user.first_name}."].join("\n\n")
  end
end
