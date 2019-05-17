class EvaluationRequirement < Expectation
  belongs_to :analyst, foreign_key: "analyst_id", class_name:"User"
  belongs_to :evaluation, foreign_key: "owner_id", class_name:"Evaluation"
  after_create :make_item
  after_create :transaction_log

  def get_analyst
    self.analyst.present? ? self.analyst.full_name : ""
  end

  def make_item
    EvaluationItem.create({
      :title            => self.title,
      :department       => self.department,
      :owner_id         => self.owner_id,
      :reference_number => self.reference_number,
      :revision_level   => self.revision_level,
      :revision_date    => self.revision_date,
      :instructions     => self.instruction,
      :user_id          => self.user_id,
      :reference        => self.reference,
      :requirement      => self.expectation,
      :status           => self.evaluation.status
    })
  end


  def transaction_log
    EvaluationTransaction.create(:users_id=>session[:user_id], :action=>"Add Requirement", :content=>self.title, :owner_id=>self.owner_id, :stamp=>Time.now)
    #InspectionTransaction.create(:users_id=>current_user.id,:action=>"Open",:owner_id=>inspection.id,:stamp=>Time.now)
  end
end
