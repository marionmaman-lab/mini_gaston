class ChatsController < ApplicationController
  def index
    @chats = current_user.chats.order(created_at: :desc)
  end

  def create
    @chat = Chat.new(title: Chat::DEFAULT_TITLE, user: current_user)

    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to chats_path, alert: "Impossible de créer la conversation."
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @chats = current_user.chats.order(created_at: :desc)
    @message = Message.new
  end

  def destroy
    chat = current_user.chats.find(params[:id])
    chat.destroy

    # Suppression depuis la page liste : on reste sur la liste
    if params[:current_chat_id].blank?
      return redirect_to chats_path, notice: "Conversation supprimée.", status: :see_other
    end

    # La conversation qu'on regardait, sinon la plus récente qui reste
    current = current_user.chats.find_by(id: params[:current_chat_id])
    current ||= current_user.chats.order(created_at: :desc).first

    if current
      redirect_to chat_path(current, history: "open"),
                  notice: "Conversation supprimée.", status: :see_other
    else
      redirect_to chats_path, notice: "Conversation supprimée.", status: :see_other
    end
  end
end
