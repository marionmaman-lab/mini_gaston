class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :user
  has_one :recipe


TITLE_PROMPT = <<~PROMPT
    Génère un titre court (3 à 6 mots) qui résume la demande de l’utilisateur.
    Réponds uniquement avec le titre, sans guillemets.
  PROMPT

  def generate_title_from_first_message
    return unless title == DEFAULT_TITLE

    first_user_message = messages.where(role: “user”).order(:created_at).first
    return if first_user_message.nil?

    response = RubyLLM.chat.with_instructions(TITLE_PROMPT).ask(first_user_message.content)
    update(title: response.content)
  end
end
