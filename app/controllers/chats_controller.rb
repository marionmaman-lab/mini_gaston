class ChatsController < ApplicationController
  def index
    @chats = chats_with_messages
  end

  def create
    # Réutilise une conversation vide si elle existe, sinon en crée une
    @chat = current_user.chats.where.missing(:messages).first ||
            Chat.new(title: Chat::DEFAULT_TITLE, user: current_user)

    if @chat.persisted? || @chat.save
      # On transmet d'où l'on vient pour afficher le bouton "Retour"
      redirect_to chat_path(@chat, back_to: params[:back_to], from: params[:from])
    else
      redirect_to chats_path, alert: "Impossible de créer la conversation."
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @chats = chats_with_messages
    @message = Message.new
    # Conversation de départ (si on vient d'une autre conversation)
    @back_chat = current_user.chats.find_by(id: params[:back_to])
  end

  def destroy
    chat = current_user.chats.find(params[:id])
    chat.destroy

    # Suppression depuis la page liste : on reste sur la liste
    if params[:current_chat_id].blank?
      return redirect_to chats_path, notice: "Conversation supprimée.", status: :see_other
    end

    # La conversation qu'on regardait, sinon la plus récente qui a des messages
    current = current_user.chats.find_by(id: params[:current_chat_id])
    current ||= chats_with_messages.first

    if current
      redirect_to chat_path(current, history: "open"),
                  notice: "Conversation supprimée.", status: :see_other
    else
      redirect_to chats_path, notice: "Conversation supprimée.", status: :see_other
    end
  end

  private

  # Seulement les conversations qui ont au moins un message
  def chats_with_messages
    current_user.chats.where.associated(:messages).distinct.order(created_at: :desc)
  end
end
