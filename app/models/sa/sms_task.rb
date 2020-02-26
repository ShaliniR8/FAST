class SmsTask < ActiveRecord::Base

#Association List
  belongs_to :res_user,        foreign_key:'res',       class_name:"User"
  belongs_to :final_approver,  foreign_key:'app_id',    class_name:"User"
  belongs_to :owner,           polymorphic: true

  after_create :transaction_log

  def transaction_log
    Transaction.build_for(
      self.owner,
      'Add Task',
      (session[:simulated_id] || session[:user_id] rescue nil),
      "##{self.id} #{self.title}"
    )
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
      { field: "due_date",        title: "Scheduled Completion Date", num_cols: 6,  type: "date",         visible: 'form,show',         required: false},
      { field: "res",             title: "Responsible User Name",     num_cols: 6,  type: "user",         visible: 'form,show',         required: false},
      { field: "app_id",          title: "Final Approver",            num_cols: 6,  type: "user",         visible: 'form,show',         required: false},
      { field: "department",      title: "Responsible Department",    num_cols: 6,  type: "text",         visible: 'form,show',         required: false},
      { field: "action",          title: "Action",                    num_cols: 6,  type: "text",         visible: 'form,show',         required: false},
      {                                                                             type: "newline",      visible: 'form,show'},
      { field: "description",     title: "Description",               num_cols: 12, type: "textarea",     visible: 'form,show',         required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end
end
