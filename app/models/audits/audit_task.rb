class AuditTask < SmsTask
	belongs_to :audit,foreign_key:"owner_id",class_name:"Audit"

	after_create :transaction_log

	def transaction_log
		AuditTransaction.create(:users_id=>session[:user_id], :action=>"Add Task", :content=>"##{self.id} #{self.title}", :owner_id=>self.owner_id, :stamp=>Time.now)
		#InspectionTransaction.create(:users_id=>current_user.id,:action=>"Open",:owner_id=>inspection.id,:stamp=>Time.now)
	end

end