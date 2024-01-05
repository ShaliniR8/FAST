class SmsTask < ActiveRecord::Base

  include Noticeable
  include ModelHelpers

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
      { field: "id",              title: "ID",                        num_cols: 6,  type: "text",         visible: 'index',             required: true},
      { field: "title",           title: "Title",                     num_cols: 6,  type: "text",         visible: 'index,form,show',   required: false},
      { field: "status",          title: "Status",                    num_cols: 6,  type: "text",         visible: 'index,show',        required: false},
      { field: "due_date",        title: "Scheduled Completion Date", num_cols: 6,  type: "date",         visible: 'form,show',         required: true},
      { field: "close_date",      title: "Actual Completion Date",    num_cols: 6,  type: "date",         visible: 'show',              required: false},
      { field: "res",             title: "Responsible User Name",     num_cols: 6,  type: "user",         visible: 'auto,form,show',         required: false, censor_deid: true},
      { field: "app_id",          title: "Final Approver",            num_cols: 6,  type: "user",         visible: 'auto,form,show',         required: false, censor_deid: true},
      { field: "department",      title: "Responsible Department",    num_cols: 6,  type: "select",       visible: 'form,show',         required: false,   options: CONFIG.custom_options['Departments']},
      { field: "action",          title: "Action",                    num_cols: 6,  type: "select",         visible: 'form,show',         required: false,   options: CONFIG.custom_options['Actions Taken']},
      {                                                                             type: "newline",      visible: 'form,show'},
      { field: "res_comment",     title: "Responsible User Comment",  num_cols: 12, type: "textarea",     visible: 'show',              required: false},
      { field: "final_comment",   title: "Final Comment",             num_cols: 12, type: "textarea",     visible: 'show',              required: false},
      { field: "description",     title: "Description",               num_cols: 12, type: "textarea",     visible: 'form,show',         required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'auto'] : args)
    keys = SmsTask.get_meta_fields(nil).select { |val| (val[:visible].split(',') & visible_fields).any? }
                                          .map { |key| key[:field].to_s }

    keys
  end

  def get_statuses
    ["New", "Assigned", "Pending Approval", "Completed"]
  end
end
