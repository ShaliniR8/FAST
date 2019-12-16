class SafetyPlan < ActiveRecord::Base
  extend AnalyticsFilters
  include ModelHelpers

#Concerns List
  include Attachmentable
  include Commentable
  include Occurrenceable
  include Transactionable

#Associations List
  belongs_to :created_by, foreign_key: "created_by_id", class_name: "User"

  after_create :create_transaction

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',                             title: 'ID',                                num_cols: 6,  type: 'text',       visible: 'index,show',      required: true},
      {field: 'status',                         title: 'Status',                            num_cols: 6,  type: 'text',       visible: 'index,show',      required: false},
      {field: 'title',                          title: 'Title',                             num_cols: 12, type: 'text',       visible: 'index,form,show', required: true},
      {                                                                                                   type: 'newline',    visible: 'show'},

      {field: 'risk_factor',                    title: 'Baseline Risk',                     num_cols: 12, type: 'select',     visible: 'index,form,show', required: false,  options: get_custom_options('Risk Factors')},
      {field: 'concern',                        title: 'Concern',                           num_cols: 12, type: 'textarea',   visible: 'form,show',       required: false},
      {field: 'objective',                      title: 'Objective',                         num_cols: 12, type: 'textarea',   visible: 'form,show',       required: false},
      {field: 'background',                     title: 'Background',                        num_cols: 12, type: 'textarea',   visible: 'form,show',       required: false},

      #The following are for if the safety plan was evaluated
      {                                         title: "Evaluation",                        num_cols: 12, type: 'panel_start',visible: 'show,eval'},
      {field: 'time_period',                    title: 'Time Period (Days)',                num_cols: 6,  type: 'text',       visible: 'show,eval',       required: false},
      {field: 'date_started',                   title: 'Date Started',                      num_cols: 6,  type: 'date',       visible: 'show,eval',       required: false},
      {field: 'date_completed',                 title: 'Date Completed',                    num_cols: 6,  type: 'date',       visible: 'show,eval',       required: false},
      {field: 'result',                         title: 'Result',                            num_cols: 6,  type: 'select',     visible: 'show,eval',       required: false,  options: get_custom_options('Results')},
      {field: 'risk_factor_after',              title: 'Mitigated Risk',                    num_cols: 6,  type: 'select',     visible: 'index,eval,show', required: false,  options: get_custom_options('Risk Factors')},
      {                                                                                                   type: 'panel_end',  visible: 'show,eval'}
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
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
