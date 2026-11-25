class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    Tu es Mini-Gaston, un chef cuisinier bienveillant.
    L'utilisateur te donne les ingrédients de son frigo.
    Propose 1 recette.
    Pour chaque recette : titre, temps, difficulté, nombre de portions,
    ingrédients avec quantités et étapes.
    Réponds en français, en Markdown.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history

      response = @ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)

      Message.create!(
        role: "assistant",
        content: response.content,
        chat: @chat
      )

      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def build_conversation_history
    @chat.messages.where.not(id: @message.id).order(:created_at).each do |message|
      @ruby_llm_chat.add_message(role: message.role, content: message.content)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
