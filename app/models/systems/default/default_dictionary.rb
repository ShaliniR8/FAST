class DefaultDictionary
  include ConfigTools
  # DO NOT COPY - This is a dictionary of default action and metadata definitions for all
    # Hierarchy and model classes - they can be overridden in the specific airline's respective
    # Module Config files

  # Default actions- used to dry out model action definitions in the HIERARCHY
    # To override within the configs, use the following:
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
      access: proc { |owner:,user:,**op| priv_check.call(owner,user,'destroy',false,true) },
    },
    edit: {
      btn: :edit,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.status != 'Completed' && priv_check.call(owner,user,'edit',true,true) },
    },
    evaluate: {
      btn: :evaluate,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op| owner.status != "Completed" },
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
    launch: {
      btn: :launch,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| CONFIG::LAUNCH_OBJECTS[owner.class.name.underscore.pluralize.to_sym].present? && priv_check.call(owner,user,'edit',true,true) },
    },
    hazard: {
      btn: :hazard,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        owner.status != 'Completed' &&
        priv_check.call(owner,user,'new',true,true)
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
      access: proc { |owner:,user:,**op| priv_check.call(owner,user,'admin',true,true) },
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
    reject: {
      btn: :reject,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op| owner.can_complete?(user) },
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
    risk_control: {
      btn: :risk_control,
      btn_loc: [:inline],
      access: proc { |owner:,user:,**op|
        !['Completed', 'Rejected'].include?(owner.status) && !owner.occurrence_lock?
      },
    },
    schedule_verification:{
      btn: :schedule_verification,
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
      access: proc { |owner:,user:,**op| owner.status != 'Completed'}
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
    view_hazard: {
      btn: :view_hazard,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.hazard.present? },
    },
    view_meeting: {
      btn: :view_meeting,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.meeting.present? },
    },
    view_parent: {
      btn: :view_parent,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.parents.present? || owner.owner.present? },
    },
    view_sra: {
      btn: :view_sra,
      btn_loc: [:top],
      access: proc { |owner:,user:,**op| owner.sra.present? },
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

  PANEL = {
    ## Format for Panel Elements:
    # panel_title: {
    #   partial: string of where the view file is
    #   visible: proc to determine if the panel will be visible- has user and object accessible
    #   show_btns: Conditional to determine if panel buttons should be shown
    #   data: proc to generate a hash of local parameters for the panel- will be splatted into render
    # },
    # records: { # WIP
    #   partial: '/panels/records',
    #   visible: proc { |owner:,user:,**op| owner.owner.present? },
    #   show_btns: proc { |owner:,user:,**op| false },
    #   data: proc { |owner:,user:,**op| {
    #     records: Array(owner.owner),
    #     title: 'Report'
    #   }},
    # },
    source_of_input: {
      partial: '/panels/source_of_input',
      visible: proc { |owner:,user:,**op| owner.parents.present? || owner.owner.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        parent: owner.get_parent.present? ? owner.get_parent : owner.owner
      }},
    },
    attachments: {
      partial: '/panels/attachments',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| { attachments: owner.attachments} },
    },
    checklists: {
      partial: '/panels/checklists',
      visible: proc { |owner:,user:,**op| owner.owner.class.name == "ChecklistRow" },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { checklist: owner.owner.checklist, checklist_row: owner.owner } },
    },
    comments: {
      partial: '/panels/comments',
      visible: proc { |owner:,user:,**op| owner.comments.present? },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| { comments: owner.comments.preload(:viewer) } },
    },
    contacts: {
      partial: '/panels/contacts',
      visible: proc { |owner:,user:,**op| owner.contacts.present? },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        parent: owner.get_parent.present? ? owner.get_parent : owner.owner
      }},
    },
    records: {
      partial: '/panels/records',
      print_partial: '/pdfs/print_records',
      visible: proc { |owner:,user:,**op| owner.owner.class.name == 'Record' },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { record: owner.owner } },
    },
    reports: {
      partial: '/panels/reports',
      print_partial: '/pdfs/print_reports',
      visible: proc { |owner:,user:,**op| owner.owner.class.name == 'Report' },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { report: owner.owner } },
    },
    investigations: {
      partial: '/panels/investigations',
      visible: proc { |owner:,user:,**op| owner.get_children(child_type: 'Investigation').present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { investigations: owner.get_children(child_type: 'Investigation') } },
    },
    findings: {
      partial: '/panels/findings',
      print_partial: '/pdfs/print_findings',
      visible: proc { |owner:, user:, **op| owner.findings.present? },
      show_btns: proc { |owner:, user:, **op| false },
      data: proc do |owner:, user:, **op|
        has_checklists = owner.class.method_defined?(:checklists)
        findings = owner.findings
        if has_checklists
          owner.checklists.each do |checklist|
            checklist.checklist_rows.each do |checklist_row|
              checklist_row.findings.each do |finding|
                findings << finding
              end
            end
          end
        end
        { findings: findings }
      end
    },
    sms_actions: { # WIP
      partial: '/sms_actions/show_all',
      print_partial: '/pdfs/print_sms_actions',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { owner: owner } },
    },
    recommendations: { # WIP
      partial: '/recommendations/show_all',
      print_partial: '/pdfs/print_recommendations',
      visible: proc { |owner:,user:,**op| owner.recommendations.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { owner: owner } },
    },
    included_sras: {
      partial: '/panels/sras',
      print_partial: '/pdfs/print_sras',
      visible: proc { |owner:,user:,**op| owner.becomes(SrmMeeting).sras.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { sras: owner.becomes(SrmMeeting).sras } },
    },
    sras: {
      partial: '/panels/sras',
      print_partial: '/pdfs/print_sras',
      visible: proc { |owner:,user:,**op| owner.get_children(child_type: 'Sra').present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { sras: owner.get_children(child_type: 'Sra') } },
    },
    hazards: {
      partial: '/panels/hazards',
      print_partial: '/pdfs/print_hazards',
      visible: proc { |owner:,user:,**op| owner.hazards.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        hazards: owner.hazards
      }},
    },
    risk_controls: { # WIP
      partial: '/panels/risk_controls',
      print_partial: '/pdfs/print_risk_controls',
      visible: proc { |owner:,user:,**op| owner.risk_controls.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        risk_controls: owner.risk_controls
      }},
    },
    occurrences: {
      partial: '/occurrences/occurrences_panel',
      print_partial: '/pdfs/print_occurrences',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| { owner: owner } },
    },
    participants: {
      print_partial: '/pdfs/print_participants',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| { owner: owner, hide_btns: true } },
    },
    requirements: { # WIP
      partial: '/audits/show_requirements',
      print_partial: '/pdfs/print_requirements',
      visible: proc { |owner:,user:,**op| owner.requirements.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { owner: owner, type: owner.class.name.downcase } },
    },
    risk_assessment: { # WIP (only works for Hazards)
      partial: 'shared/choose_show_matrix',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| true },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        type: 'hazards',
        allow_mitigate: true,
        show_btn: true,
        can_change: owner.status != 'Completed' && priv_check.call(owner,user,'hazards','edit')
      }},
    },
    root_causes: { # WIP
      partial: '/panels/root_causes',
      visible: proc { |owner:,user:,**op| CONFIG::GENERAL[:has_root_causes] },
      show_btns: proc { |owner:,user:,**op|
        ['New', 'Assigned'].include? owner.status
      },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        headers: RootCause.get_headers
      }},
    },
    signatures: {
      partial: '/panels/signatures',
      print_partial: '/pdfs/print_signatures',
      visible: proc { |owner:,user:,**op| owner.signatures.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| {
        signatures: owner.signatures,
        fields: Signature.get_meta_fields('show')
      }},
    },
    tasks: { # WIP
      partial: '/ims/show_task',
      print_partial: '/pdfs/print_tasks',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        fields: SmsTask.get_meta_fields('show')
      }},
    },
    transaction_log: {
      partial: '/panels/transaction_log',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| {
        transactions: owner.transactions.preload(:user, :owner) #owner is for get_user_name
      }},
    },
    extension_requests: {
      partial: '/extension_requests/show_extension_requests',
      print_partial: '/pdfs/print_extension_requests',
      visible: proc { |owner:, user:, **op| owner.extension_requests.present?},
      show_btns: proc { |owner:, user:, **op| true},
      data: proc { |owner:, user:, **op| {
        records: owner.extension_requests
      }},
    },
    verifications: {
      partial: '/verifications/show_verifications',
      print_partial: '/pdfs/print_verifications',
      visible: proc { |owner:, user:, **op| owner.verifications.present?},
      show_btns: proc { |owner:, user:, **op| true},
      data: proc { |owner:, user:, **op| {
        records: owner.verifications
      }},
    },
    agendas: {
      partial: '/panels/agendas',
      visible: proc { |owner:,user:,**op| owner.srm_agendas.present? },
      show_btns: proc { |owner:,user:,**op| false },
      data: proc { |owner:,user:,**op| { sra: owner } },
    },
    attachments: {
      partial: '/panels/attachments',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| { attachments: owner.attachments} },
    },
    comments: {
      partial: '/panels/comments',
      print_partial: '/pdfs/print_comments',
      visible: proc { |owner:,user:,**op| owner.comments.present? },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| { comments: owner.comments.preload(:viewer) } },
    },
    contacts: {
      partial: '/panels/contacts',
      print_partial: '/pdfs/print_contacts',
      visible: proc { |owner:,user:,**op| owner.contacts.present? },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| {
        fields: Contact.get_meta_fields('show'),
        contacts: owner.contacts
      }},
    },
    costs: {
      partial: '/panels/costs',
      print_partial: '/pdfs/print_costs',
      visible: proc { |owner:,user:,**op| owner.costs.present? },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| { costs: owner.costs } },
    },
    descriptions: {
      partial: '/causes/all',
      visible: proc { |owner:,user:,**op| true },
      show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
      data: proc { |owner:,user:,**op| {
        owner: owner,
        cause_type: 'description',
        can_change: owner.status == 'New' && priv_check.call(owner,user,'edit',true)
      }},
    },
  }

  META_DATA = {
    id: {
      field: 'id', title: 'ID',
      num_cols: 6, type: 'text', visible: 'index,show',
      required: false
    },
    title: {
      field: 'title', title: 'Title',
      num_cols: 6, type: 'text', visible: 'index,form,show',
      required: true
    },
    status: {
      field: 'get_status', title: 'Status',
      num_cols: 6,  type: 'text', visible: 'index,show',
      required: false
    },
    created_by: {
      field: 'created_by_id', title: 'Created By',
      num_cols: 6,  type: 'user', visible: 'show',
      required: false
    },
    viewer_access: {
      field: 'viewer_access', title: 'Viewer Access',
      num_cols: 6,  type: 'boolean_box', visible: 'show',
      required: false
    },
    due_date: {
      field: 'due_date', title: 'Scheduled Completion Date',
      num_cols: 6,  type: 'date', visible: 'index,form,show',
      required: true
    },
    close_date: {
      field: 'close_date', title: 'Actual Completion Date',
      num_cols: 6,  type: 'date', visible: 'index,show',
      required: false
    },
    responsible_user: {
      field: 'responsible_user_id', title: 'Responsible User',
      num_cols: 6,  type: 'user', visible: 'index,form,show',
      required: false, display: 'get_responsible_user_name'
    },
    approver: {
      field: 'approver_id', title: 'Final Approver',
      num_cols: 6,  type: 'user', visible: 'form,show',
      required: false, display: 'get_approver_name'
    },
    location: {
      field: 'location', title: 'Location',
      num_cols: 6,  type: 'text', visible: 'form,show',
      required: false
    },
    vendor: {
      field: 'vendor', title: 'Vendor',
      num_cols: 6,  type: 'text', visible: 'form,show',
      required: false
    },
    process: {
      field: 'process', title: 'Process',
      num_cols: 6,  type: 'text', visible: 'form,show',
      required: false
    },
    planned: {
      field: 'planned', title: 'Planned',
      num_cols: 6,  type: 'boolean_box', visible: 'form,show',
      required: false
    },
    objective: {
      field: 'objective', title: 'Objective and Scope',
      num_cols: 12, type: 'textarea', visible: 'form,show',
      required: false
    },
    reference: {
      field: 'reference', title: 'References and Requirements',
      num_cols: 12, type: 'textarea', visible: 'form,show',
      required: false
    },
    instruction: {
      field: 'instruction', title: 'Instructions',
      num_cols: 12, type: 'textarea', visible: 'form,show',
      required: false
    },
    comment: {
      field: 'comment', title: 'Comment',
      num_cols: 12, type: 'textarea', visible: 'form,show',
      required: false
    },
    likelihood: {
      field: 'likelihood', title: 'Baseline Likelihood',
      num_cols: 12, type: 'text', visible: 'adv',
      required: false
    },
    severity: {
      field: 'severity', title: 'Baseline Severity',
      num_cols: 12, type: 'text', visible: 'adv',
      required: false
    },
    risk_factor: {
      field: 'get_risk_classification', title: 'Baseline Risk',
      num_cols: 12, type: 'text', visible: 'index',
      required: false,  html_class: 'get_before_risk_color'
    },
    risk_score: {
      field: 'get_risk_score', title: 'Baseline Risk Score',
      num_cols: 12, type: 'text', visible: 'query',
      required: false,  html_class: 'get_before_risk_color'
    },
    likelihood_after: {
      field: 'likelihood_after', title: 'Mitigated Likelihood',
      num_cols: 12, type: 'text', visible: 'adv',
      required: false
    },
    severity_after: {
      field: 'severity_after', title: 'Mitigated Severity',
      num_cols: 12, type: 'text', visible: 'adv',
      required: false
    },
    risk_factor_after: {
      field: 'get_risk_classification_after', title: 'Mitigated Risk',
      num_cols: 12, type: 'text', visible: 'index',
      required: false,  html_class: 'get_after_risk_color'
    },
    risk_score_after: {
      field: 'get_risk_score_after', title: 'Baseline Risk Score',
      num_cols: 12, type: 'text', visible: 'query',
      required: false,  html_class: 'get_before_risk_color'
    },

    final_comment: {
      field: 'final_comment', title: 'Final Comment',
      num_cols: 12, type: 'textarea', visible: 'show',
      required: false
    },
    verifications: {
      field: 'included_verifications', title: 'Verifications',
      num_cols: 6,  type: 'text', visible: 'index',
      required: false
    },
    template: {
      field: 'get_template', title: 'Template Type',
      num_cols: 6, type: 'text', visible: 'index,show',
      required: false
    },
    submitter: {
      field: 'get_submitter_name', title: 'Submitted By',
      num_cols: 6, type: 'user', visible: 'admin', #should include show+form w/ sr::CONFIG[:show_submitter_name]
      required: false, censor_deid: true
    },
    event_date: {
      field: 'event_date', title: 'Event Date/Time',
      num_cols: 6, type: 'datetime', visible: 'index,show',
      required: false
    },
    # root_causes_full: {
    #   field: 'get_root_causes_full', title: 'Full Root Causes',
    #   type: 'list', visible: 'invisible'
    # },
    # root_causes: {
    #   field: 'get_root_causes', title: 'Root Causes',
    #   type: 'list', visible: '' #should include index w/ CONFIG[:has_root_causes]
    # },
    occurrences: {
      field: 'get_occurrences', title: 'Occurrences',
      type: 'list', visible: 'index'
    },
    occurrences_full: {
      field: 'get_occurrences_full', title: 'Occurrences Full',
      type: 'category', visible: 'index'
    },
    # occurrences_category: {
    #   field: 'get_occurrence_category', title: 'Occurrence Category',
    #   type: 'list', visible: 'index'
    # },
    # occurrences_subcategory: {

    # },
    # occurrences_value: {

    # },
    description: {
      field: 'description', title: 'Event Title',
      num_cols: 12, type: 'text', visible: 'index,show',
      required: false
    },
  }

end
