class MessageAccess < ActiveRecord::Base
	belongs_to :message, foreign_key:"messages_id", class_name: "Message"
	belongs_to :user,foreign_key:"users_id",class_name: "User"

	def getName
		self.user.full_name
	end
end
