class DefaultDictionary
  include ConfigTools
  # DO NOT COPY - This is a dictionary of default action and metadata definitions for all
    # Hierarchy and model classes - they can be overridden in the specific airline's respective
    # Module Config files

  # Default actions- used to dry out model action definitions in the HIERARCHY
    # To override, use the following:
      # DICTIONARY:ACTIONS[|__action__|))].tap{|act| act[:access] = proc { ... } },
  ACTION = {
    # { btn: btn_loc:[], access: proc { |owner:,user:,**op| } },
    approve_reject: {
      btn: :approve_reject,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        form_confirmed = owner.status == 'Pending Approval' || op[:form_conds]
        user_confirmed = [owner.created_by_id, owner.approver_id].include?(user.id) ||
          priv_check.call(owner,user,'admin',true,true) ||
          op[:user_conds]
        form_confirmed && user_confirmed
      },
    },
    assign: {
      btn: :assign,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        form_confirmed = owner.status == 'New' || op[:form_conds]
        user_confirmed = [owner.created_by_id, owner.approver_id].include?(user.id) ||
          priv_check.call(owner,user,'admin',true,true) ||
          op[:user_conds]
        form_confirmed && user_confirmed
      },
    },
    attach_in_message: {
      btn: :attach_in_message,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| true },
    },
    comment: {
      btn: :comment,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op| true },
    },
    complete: {
      btn: :complete,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        form_confirmed = owner.status == 'Assigned' || op[:form_conds]
        user_confirmed = [owner.created_by_id, owner.responsible_user_id].include?(user.id) ||
          priv_check.call(owner,user,'admin',true,true) ||
          op[:user_conds]
        form_confirmed && user_confirmed
      },
    },
    contact: {
      btn: :contact,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
    },
    cost: {
      btn: :cost,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
    },
    deid_pdf: {
      btn: :deid_pdf,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| true },
    },
    delete:{
      btn: :delete,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| priv_check.call(owner,user,'destroy',true,true) },
    },
    edit: {
      btn: :edit,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| priv_check.call(owner,user,'edit',true,true) },
    },
    expand_all: {
      btn: :expand_all,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| true },
    },
    finding: {
      btn: :finding,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
    },
    hazard: {
      btn: :hazard,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        owner.status != 'Completed' &&
        user.has_access('hazard', 'new', admin:true, strict:true)
      },
    },
    message_submitter: {
      btn: :message_submitter,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| true },
    },
    override_status: {
      btn: :override_status,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| priv_check.call(owner,user,'admin',true,true) },
    },
    pdf: {
      btn: :pdf,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| true },
    },
    private_link: {
      btn: :private_link,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op|
        CONFIG::GENERAL[:shared_links] && priv_check.call(owner,user,'admin',true,true)
      },
    },
    recommendation: {
      btn: :recommendation,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        form_confirmed = owner.status == 'Assigned' || op[:form_conds]
        user_confirmed = [owner.created_by_id, owner.responsible_user_id].include?(user.id) ||
          priv_check.call(owner,user,'admin',true,true) ||
          op[:user_conds]
        form_confirmed && user_confirmed
      },
    },
    reopen: {
      btn: :reopen,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        next false unless CONFIG::GENERAL[:allow_reopen_report]
        form_confirmed = owner.status == 'Completed' || op[:form_conds]
        user_confirmed = [owner.created_by_id].include?(user.id) ||
          priv_check.call(owner,user,'admin',true,true) ||
          op[:user_conds]
        form_confirmed && user_confirmed
      },
    },
    request_extension: {
      btn: :request_extension,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        CONFIG::GENERAL[:has_extension] && owner.status == 'Assigned'
      },
    },
    schedule_validation:{
      btn: :schedule_validation,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        CONFIG::GENERAL[:has_verification] && owner.status == 'Completed'
      },
    },
    send_message: {
      btn: :send_message,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| user.id.present? },
    },
    set_alert: {
      btn: :set_alert,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| CONFIG::GENERAL[:allow_set_alert] },
    },
    sign: {
      btn: :sign,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| true }
    },
    sms_action: {
      btn: :sms_action,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        form_confirmed = ['Assigned'].include?(owner.status) || op[:form_conds]
        user_confirmed = [owner.responsible_user, owner.approver].include?(user) ||
          priv_check.call(owner,user,'admin',true,true) ||
          op[:user_conds]
        form_confirmed && user_confirmed
      }
    },
    task: {
      btn: :task,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
    },
    view_event: {
      btn: :view_event,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.report.present? },
    },
    view_meeting: {
      btn: :view_meeting,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.meeting.present? },
    },
    view_parent: {
      btn: :view_parent,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.owner.present? },
    },
    view_report: {
      btn: :view_report,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.record.present? && user.has_access('ASAP','module') },
    },
    viewer_access: {
      btn: :viewer_access,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| priv_check.call(owner,user,'edit',true,true)
      },
    },
  }

  META_DATA = {

  }
end
