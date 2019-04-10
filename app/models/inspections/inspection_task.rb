class InspectionTask < SmsTask
	belongs_to :inspection,foreign_key:"owner_id",class_name:"Inspection"

	after_create :transaction_log

	def transaction_log
		InspectionTransaction.create(:users_id=>session[:user_id], :action=>"Add Task", :content=>"##{self.id} #{self.title}", :owner_id=>self.owner_id, :stamp=>Time.now)
		#InspectionTransaction.create(:users_id=>current_user.id,:action=>"Open",:owner_id=>inspection.id,:stamp=>Time.now)
	end

end