class DefaultSafetyRiskManagementConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:

    # Airline-Specific Features:
    risk_assess_sras:         false,
    add_reports_to_sra:       false,
    enable_risk_register:     true,
    one_page_sra:             false,
    enable_sra_viewer_access: false, # by default Viewer Access on SRAs will be enabled if true. Needed for SCX workflow
    allow_sra_reuse:          false
  }

  HIERARCHY = {
    display_name: 'Safety Risk Management',
    display_workflow_diagram_module: false,
    objects: {

      'Sra' => {
        title: 'SRA',
        status: ['New', 'Assigned', 'Pending Review', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true, field: 'get_id' },
          status: { default: true },
          source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          title: { default: true, title: 'SRA Title', on_newline: true },
          viewer_access: { default: true, on_newline: true },
          sra_type: {
            field: 'sra_type', title: "Level of SRA",
            num_cols: 6, type: 'text', visible: '',
            required: false
          },
          type_of_change: {
            field: 'type_of_change', title: 'Type of Change',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['SRA Type of Change']"
          },
          system_task: {
            field: 'system_task', title: 'System/Task',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['Systems/Tasks']"
          },
          created_by: { default: true },
          responsible_user: { default: true },
          reviewer: {
            field: 'reviewer_id', title: 'Quality Reviewer',
            num_cols: 6, type: 'user', visible: 'form,show,auto',
            required: false
          },
          approver: { default: true },
          due_date: { default: true,
            field: 'due_date',
            required: true
          },
          close_date: { default: true },
          description: {
            field: 'current_description', title: 'Describe the Current System',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          plan_description: {
            field: 'plan_description', title: 'Describe Proposed Plan',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          closing_comment: {
            field: 'closing_comment', title: "Responsible User's Comments",
            num_cols: 12, type: 'text', visible: 'show',
            required: false
          },
          reviewer_comment: {
            field: 'reviewer_comment', title: "Quality Reviewer's Comments",
            num_cols: 12, type: 'text', visible: 'show',
            required: false
          },
          approver_comment: {
            field: 'approver_comment', title: "Final Approver's Comments",
            num_cols: 12, type: 'text', visible: 'show',
            required: false
          },
          departments_panel_start: {
            title: 'Affected Department',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          departments: {
            field: 'departments', title: 'Affected Departments',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          other_department: {
            field: 'other_department', title: 'Other Affected Departments',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          departments_comment: {
            field: 'departments_comment', title: 'Affected Departments Comments',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          departments_panel_end: {
            num_cols: 12, type: 'panel_end', visible: 'form,show'
          },
          programs_panel_start: {
            title: 'Affected Programs',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          programs: {
            field: 'programs', title: 'Affected Programs',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Programs']"
          },
          other_program: {
            field: 'other_program', title: 'Other Affected Programs',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          programs_comment: {
            field: 'programs_comment', title: 'Affected Programs Comments',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          programs_panel_end: {
            num_cols: 12, type: 'panel_end', visible: 'form,show'
          },
          manuals_panel_start: {
            title: 'Affected Manuals',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          manuals: {
            field: 'manuals', title: 'Affected Manuals',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Manuals']"
          },
          other_manual: {
            field: 'other_manual', title: 'Other Affected Manuals',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          manuals_comment: {
            field: 'manuals_comment', title: 'Affected Manuals Comments',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          manuals_panel_end: {
            num_cols: 12, type: 'panel_end', visible: 'form,show'
          },
          regulatory_compliances_panel_start: {
            field: 'compliances', title: 'Affected Regulatory Compliances',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          compliances: {
            field: 'compliances', title: 'Affected Regulatory Compliances',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Regulatory Compliances']"
          },
          other_compliance: {
            field: 'other_compliance', title: 'Other Affected Regulatory Compliances',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          compliances_comment: {
            field: 'compliances_comment', title: 'Affected Regulatory Compliances Comments',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          regulatory_compliances_panel_end: {
            num_cols: 12, type: 'panel_end', visible: 'form,show'
          },
          verifications: { default: true },
          likelihood: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Likelihood" },
          severity: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Severity" },
          risk_factor: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Risk" },
          likelihood_after: { default: true, title: "#{I18n.t('srm.risk.mitigated.title')} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t('srm.risk.mitigated.title')} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t('srm.risk.mitigated.title')} Risk" },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf viewer_access view_meeting view_parent attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject add_records hazard reopen comment contact task cost],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          approve_reject: {
            btn: :approve_reject,
            btn_loc: [:inline],
            access: proc { |owner:,user:,**op|
              form_confirmed = owner.status == 'Pending Approval' || op[:form_conds] || owner.status == 'Pending Review'
              user_confirmed = priv_check.call(owner,user,'admin',CONFIG::GENERAL[:global_admin_default],true) ||
                               op[:user_conds] ||
                               (owner.status == "Pending Approval" && owner.approver_id == user.id) ||
                               (owner.status == "Pending Review" && owner.reviewer_id == user.id)
              form_confirmed && user_confirmed
            },
          },
          contact: {
            access: proc { |owner:,user:,**op|
              owner.sra_type == 'Level 2'
            },
          },
          task: {
            access: proc { |owner:,user:,**op|
              owner.sra_type == 'Level 2'
            },
          },
          cost: {
            access: proc { |owner:,user:,**op|
              owner.sra_type == 'Level 2'
            },
          },
        }),
        panels: %i[agendas comments source_of_input audits hazards contacts costs tasks extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'Hazard' => {
        title: 'Hazard',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :sra,
          :responsible_user,
          :created_by,
          :approver,
          :occurrences,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true,
            field: 'get_id', title: 'Hazard ID'
          },
          status: { default: true },
          created_by: { default: true },
          title: { default: true,
            title: 'Hazard Title',
            required: false, on_newline: true
          },
          source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          departments: {
            field: 'departments', title: 'Department',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          responsible_user: { default: true },
          approver: { default: true },
          due_date: { default: true,
            field: 'due_date',
            required: true
          },
          description: {
            field: 'description', title: 'Description',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          closing_comment: {
            field: 'closing_comment', title: "Responsible User's Comments",
            num_cols: 12, type: 'text', visible: 'show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
          occurrences: {default: true, title: (Hazard.find_top_level_section.label rescue nil)},
          occurrences_full: {default: true,
            visible: 'query',
            title: "Full #{Hazard.find_top_level_section.label rescue nil}"},
          likelihood: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Likelihood" },
          severity: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Severity" },
          risk_factor: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Risk" },
          risk_score: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Risk Score" },
          likelihood_after: { default: true, title: "#{I18n.t('srm.risk.mitigated.title')} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t('srm.risk.mitigated.title')} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t('srm.risk.mitigated.title')} Risk" },
          risk_score_after: { default: true, title: "#{I18n.t('srm.risk.baseline.title')} Risk Score" },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_sra attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject risk_control reopen comment],
          #*%i[assign complete approve_reject reject complete_hazard risk_control reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          complete: {
            access: proc { |owner:,user:,**op|
              owner.can_complete?(user)
            },
          },
          reopen: {
            access: proc { |owner:,user:,**op|
              next false unless CONFIG::GENERAL[:allow_reopen_report]
              form_confirmed = ['Completed', 'Rejected'].include? owner.status || op[:form_conds]
              user_confirmed = [owner.created_by_id].include?(user.id) ||
                priv_check.call(owner,user,'admin',CONFIG::GENERAL[:global_admin_default],true) ||
                op[:user_conds]
              form_confirmed && user_confirmed
            },
          },
        }),
        panels: %i[risk_controls occurrences comments extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'RiskControl' => {
        title: 'Risk Control',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          status: { default: true },
          created_by: { default: true },
          title: { default: true },
          source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          departments: {
            field: 'departments', title: 'Department',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          due_date: { default: true,
            field: 'due_date',
            required: true
          },
          follow_up_date: {
            field: 'follow_up_date', title: 'Date for Follow-Up/Monitor Plan',
            num_cols: 6, type: 'date', visible: 'form,show', required: false
          },
          responsible_user: { default: true },
          approver: { default: true,
            field: 'approver_id',
            visible: 'index,form,show,auto'
          },
          faa_approval: {
            field: 'faa_approval', title: 'Requires FAA Approval',
            num_cols: 6,  type: 'boolean_box', visible: 'none',
          },
          control_type: {
            field: 'control_type', title: 'Type',
            num_cols: 6, type: 'datalist', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Risk Control Types']"
          },
          description: {
            field: 'description', title: 'Description of Risk Control/Mitigation Plan',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          notes: {
            field: 'notes', title: 'Notes',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          closing_comment: {
            field: 'closing_comment', title: "Responsible User's Comments",
            num_cols: 12, type: 'text', visible: 'show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_hazard attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen cost comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              form_confirmed = ['New', 'Open'].include? owner.status || op[:form_conds]
              user_confirmed = [owner.created_by_id, owner.approver_id].include?(user.id) ||
                priv_check.call(owner,user,'admin',CONFIG::GENERAL[:global_admin_default],true) ||
                op[:user_conds]
              form_confirmed && user_confirmed
            },
          },
          complete: {
            access: proc { |owner:,user:,**op|
              owner.can_complete?(user)
            },
          },
          edit: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:edit][:access].call(owner:owner,user:user,**op) &&
              owner.status != 'Completed'
            },
          },
        }),
        panels: %i[costs comments occurrences safety_plans extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'SafetyPlan' => {
        title: 'Safety Plan',
        status: ['New', 'Evaluated', 'Completed', 'All'],
        fields: {
          id: { default: true,
            required: true
          },
          status: { default: true },
          title: { default: true,
            num_cols: 12
          },
          risk_factor: {
            field: 'risk_factor', title: 'Baseline Risk',
            num_cols: 12, type: 'select', visible: 'index,form,show',
            required: false, on_newline: true, options: "CONFIG.custom_options['Risk Factors']"
          },
          concern: {
            field: 'concern', title: 'Concern',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          objective: {
            field: 'objective', title: 'Objective',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          background: {
            field: 'background', title: 'Background',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          evaluation_panel_start: {
            title: 'Evaluation',
            num_cols: 12, type: 'panel_start', visible: 'show,eval'
          },
          time_period: {
            field: 'time_period', title: 'Time Period (Days)',
            num_cols: 6, type: 'text', visible: 'show,eval',
            required: false
          },
          date_started: {
            field: 'date_started', title: 'Date Started',
            num_cols: 6, type: 'date', visible: 'show,eval',
            required: false
          },
          date_closed: {
            field: 'close_date', title: 'Date Completed',
            num_cols: 6, type: 'date', visible: 'show,eval',
            required: false
          },
          result: {
            field: 'result', title: 'Result',
            num_cols: 6, type: 'select', visible: 'show,eval',
            required: false,  options: "CONFIG.custom_options['Results']"
          },
          risk_factor_after: {
            field: 'risk_factor_after', title: 'Mitigated Risk',
            num_cols: 6,  type: 'select', visible: 'index,eval,show',
            required: false,  options: "CONFIG.custom_options['Risk Factors']"
          },
          evaluation_panel_end: {
            type: 'panel_end', visible: 'show,eval'
          },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit pdf attach_in_message expand_all],
          #INLINE
          *%i[complete_safety_plan evaluate reopen comment contact task cost],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          complete_safety_plan: {
            btn: :complete_safety_plan,
            btn_loc: [:inline],
            access: proc { |owner:,user:,**op|
              owner.status == 'Evaluated'
            },
          },
          edit: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:edit][:access].call(owner:owner,user:user,**op) &&
              owner.status != "Completed"
            },
          },
        }),
        panels: %i[comments source_of_input contacts costs tasks attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'Meeting' => {
        title: 'Meeting',
        fields: {
          id: { default: true, title: 'ID', num_cols: 6, type: 'text', visible: 'index,show', required: true },
          status: { default: true, title: 'Status', num_cols: 6, type: 'text', visible: 'index,show', required: false },
          get_host: { 
            field: 'get_host', title: 'Host', num_cols: 6, 
            type: 'text', visible: 'index,show', 
            required: false
          },
          meeting_type: { 
            field: 'meeting_type', title: 'Meeting Type', num_cols: 6, 
            type: 'text', visible: 'index,show,form', 
            required: false
          },
          title: { 
            field: 'title', title: 'Title', num_cols: 6, 
            type: 'datalist', visible: 'index,show,form', 
            required: false, options: "CONFIG.custom_options['Meeting Titles']"
          },
          review_start: { 
            field: 'review_start', title: 'Review Start Date', num_cols: 6, 
            type: 'datetimez', visible: 'index,form,show', 
            required: true, on_newline: true
          },
          review_end: { 
            field: 'review_end', title: 'Review End Date', num_cols: 6, 
            type: 'datetimez', visible: 'index,form,show', 
            required: true
          },
          meeting_start: { 
            field: 'meeting_start', title: 'Meeting Start Date', num_cols: 6, 
            type: 'datetimez', visible: 'index,form,show', 
            required: true
          },
          meeting_end: { 
            field: 'meeting_end', title: 'Meeting End Date', num_cols: 6, 
            type: 'datetimez', visible: 'index,form,show', 
            required: true
          },
          notes: { 
            field: 'notes', title: 'Notes', num_cols: 12, 
            type: 'textarea', visible: 'form,show', 
            required: false
          },
          final_comment: { 
            field: 'final_comment', title: 'Final Comment', num_cols: 12, 
            type: 'textarea', visible: 'show', 
            required: false
          },
          host: { 
            field: 'host', title: 'Host', num_cols: 12, 
            type: 'user', visible: 'auto', 
            required: false
          },
          participants: { 
            field: 'participants', title: 'Participants', num_cols: 12, 
            type: 'user', visible: 'auto', 
            required: false
          },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[],
          #INLINE
          *%i[pdf],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[included_sras participants attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      }
    },
    menu_items: {
      'Sra' => {
        title: 'SRA (SRM)', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Sra'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('Sra'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'sras_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Sra'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_sra_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Sra'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Hazards' => {
        title: 'Hazards', path: 'hazards_path(status: "New")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Hazard'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)},
      },
      'Risk Controls' => {
        title: 'Risk Controls', path: 'risk_controls_path(status: "New")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('RiskControl'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)},
      },
      'Risk Register' => {
        title: 'Risk Register', path: 'view_register_risk_controls_path',
        display: proc{|user:,**op| priv_check.call(Object.const_get('RiskControl'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) &&
                                   CONFIG.srm::GENERAL[:enable_risk_register]},
      },
      'Safety Plans' => {
        title: 'Safety Plans', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('SafetyPlan'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'safety_plans_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SafetyPlan'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_safety_plan_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SafetyPlan'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Meetings' => {
        title: 'Meetings', path: '#',
        display: proc{|user:,**op|
          priv_check.call(Object.const_get('SrmMeeting'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
          priv_check.call(Object.const_get('SrmMeeting'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'srm_meetings_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SrmMeeting'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_srm_meeting_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SrmMeeting'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Query Center' => {
        title: 'Query Center', path: '#',
        display: proc{|user:,**op| user.has_access('home', 'query_all', admin: CONFIG::GENERAL[:global_admin_default])},
        subMenu: [
          {title: 'All', path: 'queries_path',
            display: proc{|user:,**op| true}},
          {title: 'New', path: 'new_query_path',
            display: proc{|user:,**op| true}},
        ]
      },
    }
  }

end
