class SmsTask < ActiveRecord::Base
  belongs_to :res_user,foreign_key:'res',class_name:"User"
  belongs_to :final_approver,foreign_key:'app_id',class_name:"User"


  after_create :transaction_log

  def transaction_log
    SmsActionTransaction.create(:users_id=>session[:user_id], :action=>"Add Task", :content=>"##{self.id} #{self.title}", :owner_id=>self.owner_id, :stamp=>Time.now)
    #InspectionTransaction.create(:users_id=>current_user.id,:action=>"Open",:owner_id=>inspection.id,:stamp=>Time.now)
  end

  def get_completion
    self.completion.present? ? self.completion.strftime('%Y-%m-%d') : ""
  end

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      {                                                                             type: "newline",      visible: 'form'},
      { field: "id",              title: "ID",                        num_cols: 6,  type: "text",         visible: 'index',             required: false},
      { field: "title",           title: "Title",                     num_cols: 6,  type: "text",         visible: 'index,form,show',   required: false},
      { field: "completion",      title: "Scheduled Completion Date", num_cols: 6,  type: "date",         visible: 'form,show',         required: false},
      { field: "res",             title: "Responsible User Name",     num_cols: 6,  type: "user",         visible: 'form,show',         required: false},
      { field: "app_id",          title: "Final Approver",            num_cols: 6,  type: "user",         visible: 'form,show',         required: false},
      { field: "department",      title: "Responsible Department",    num_cols: 6,  type: "text",         visible: 'form,show',         required: false},
      { field: "action",          title: "Action",                    num_cols: 6,  type: "text",         visible: 'form,show',         required: false},
      {                                                                             type: "newline",      visible: 'form,show'},
      { field: "description",     title: "Description",               num_cols: 12, type: "textarea",     visible: 'form,show',         required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end
end
