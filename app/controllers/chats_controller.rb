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
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    redirect_to chats_path, notice: "Conversation supprimée.", status: :see_other
  end
end
