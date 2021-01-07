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


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['SafetyPlan'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                               .map { |key, _| key.to_s }
    keys
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

end
