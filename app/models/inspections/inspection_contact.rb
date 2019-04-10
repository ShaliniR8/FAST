class InspectionContact < Contact 

	after_create :transaction_log

	def transaction_log
		InspectionTransaction.create(:users_id=>session[:user_id], :action=>"Add Contact", :content=>"##{self.id} #{self.contact_name}", :owner_id=>self.owner_id, :stamp=>Time.now)
		#InspectionTransaction.create(:users_id=>current_user.id,:action=>"Open",:owner_id=>inspection.id,:stamp=>Time.now)
	end
end
