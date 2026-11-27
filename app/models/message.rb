class Message < ApplicationRecord
  belongs_to :chat
  validates :content, presence: true, if: -> { role == "user" }
  validates :role, inclusion: { in: %w[user assistant] }

  after_create_commit :broadcast_created
  after_update_commit :broadcast_updated

  private

  def broadcast_created
    broadcast_append_to chat,
                        target: "messages",
                        partial: "messages/message",
                        locals: { message: self }
  end
  def broadcast_updated
    broadcast_replace_to chat,
                         target: self,
                         partial: "messages/message",
                         locals: { message: self }
  end
  
end
