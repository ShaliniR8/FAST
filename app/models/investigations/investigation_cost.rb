class InvestigationCost < Cost
  belongs_to :investigation,foreign_key:"owner_id",class_name:"Investigation"

  after_create :transaction_log

  def transaction_log
    InvestigationTransaction.create(:users_id=>session[:user_id], :action=>"Add Cost", :content=>"##{self.id} #{self.description}", :owner_id=>self.owner_id, :stamp=>Time.now)
    #InspectionTransaction.create(:users_id=>current_user.id,:action=>"Open",:owner_id=>inspection.id,:stamp=>Time.now)
  end


  def get_date
    self.cost_date.present? ? self.cost_date.strftime("%Y-%m-%d") : ""
  end
end
