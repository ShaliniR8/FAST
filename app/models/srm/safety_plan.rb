class SafetyPlan < Srm::SafetyRiskManagementBase
  extend AnalyticsFilters
  include ModelHelpers

#Concerns List
  include Attachmentable
  include Commentable
  include Occurrenceable
  include Transactionable
  include Noticeable
  include Childable
  include Parentable

#Associations List
  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"

  after_create :create_transaction

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    CONFIG.object['SafetyPlan'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.progress
  {
    'New'               => { :score => 33,  :color => 'default'},
    'Evaluated'         => { :score => 66,  :color => 'warning'},
    'Completed'         => { :score => 100, :color => 'success'},
  }
end


  def self.results
    ['Satisfactory','Unsatisfactory']
  end


  def self.get_avg_complete
    candidates=self.where("status=? and date_completed is not ?","Completed",nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.date_completed-x.created_at.to_date).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


end
