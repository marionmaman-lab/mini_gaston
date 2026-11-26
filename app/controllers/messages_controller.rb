class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    Tu es Mini-Gaston, un chef cuisinier bienveillant.
    L'utilisateur te donne les ingrédients de son frigo.
    Propose 1 recette.
    Pour cette recette : titre, temps, difficulté, nombre de portions,
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
