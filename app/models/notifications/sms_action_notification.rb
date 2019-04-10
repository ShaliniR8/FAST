class SmsActionNotification < Notification

	belongs_to :owner, foreign_key: :owner_id, class_name: 'SmsAction'


	def create_transaction
		@table = "SmsActionTransaction"
		Object.const_get(@table).create(
			:users_id => session[:user_id],
			:action => "Set Alert",
			:owner_id => self.owner.id,
			:stamp => Time.now,
			:content => "Recipients: #{users_id.split(',').map{|id| User.find(id).full_name}.join(', ')}.  
				Date: #{notify_date}."
			)
	end

end