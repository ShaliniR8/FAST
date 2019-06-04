class Contact < ActiveRecord::Base
  belongs_to :owner, polymorphic: true


  after_create :transaction_log

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "id",                title: "ID",                            num_cols: 4,  type: "text",         visible: 'index', required: false},
      {                                                                                   type: "newline",      visible: 'form'},
      { field: "location",          title: "Supplier or Location Detail",   num_cols: 6,  type: "text",         visible: 'form,show,index', required: false},
      { field: "reference_number",  title: "Reference Number",              num_cols: 6,  type: "text",         visible: 'form,show,index', required: false},
      { field: "contact_name",      title: "Contact Name",                  num_cols: 6,  type: "text",         visible: 'form,show,index', required: false},
      { field: "email",             title: "Email",                         num_cols: 6,  type: "text",         visible: 'form,show,index', required: false},
      { field: "work_phone",        title: "Work Phone",                    num_cols: 6,  type: "text",         visible: 'form,show',   required: false},
      { field: "mobile_phone",      title: "Mobile Phone",                  num_cols: 6,  type: "text",         visible: 'form,show',   required: false},
      { field: "add_1",             title: "Address Line 1",                num_cols: 6,  type: "text",         visible: 'form,show',   required: false},
      { field: "add_2",             title: "Address Line 2",                num_cols: 6,  type: "text",         visible: 'form,show',   required: false},
      { field: "city",              title: "City",                          num_cols: 6,  type: "text",         visible: 'form,show',   required: false},
      { field: "state",             title: "State or Country",              num_cols: 6,  type: "text",         visible: 'form,show',   required: false},
      { field: "zip",               title: "Zip",                           num_cols: 6,  type: "text",         visible: 'form,show',   required: false},
      { field: "notes",             title: "Notes",                         num_cols: 12, type: "textarea",     visible: 'form,show',   required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def transaction_log
    Transaction.build_for(
      self.owner,
      'Add Contact',
      session[:user_id],
      "##{self.id} #{self.contact_name}",
      nil,
      User.new(:username => session[:digest].name, :email => session[:digest].email)
    )
  end

end
