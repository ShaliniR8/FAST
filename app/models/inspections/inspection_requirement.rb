class InspectionRequirement < Expectation
  belongs_to :analyst,foreign_key:"analyst_id",class_name:"User"
  belongs_to :inspection,foreign_key:"owner_id",class_name:"Inspection"
  after_create :make_item
  after_create :transaction_log


  def get_analyst
    self.analyst.present? ? self.analyst.full_name : ""
  end
  def make_item
    InspectionItem.create({
      :title=>self.title,
      :department=>self.department,
      :owner_id=>self.owner_id,
      :reference_number=>self.reference_number,
      :revision_level=>self.revision_level,
      :revision_date=>self.revision_date,
      :instructions=>self.instruction,
      :user_id=>self.user_id,
      :reference=>self.reference,
      :requirement=>self.expectation,
      :status=>self.inspection.status
    })
  end

  def transaction_log
    InspectionTransaction.create(:users_id=>session[:user_id], :action=>"Add Requirement", :content=>self.title, :owner_id=>self.owner_id, :stamp=>Time.now)
    #InspectionTransaction.create(:users_id=>current_user.id,:action=>"Open",:owner_id=>inspection.id,:stamp=>Time.now)
  end


end
