class MessageAttachment < Attachment
  belongs_to :message, foreign_key:"owner_id", class_name: "Message"
end
