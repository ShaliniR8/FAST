class DefaultSafetyAssuranceConfig
  include ConfigTools

  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:
    checklist_version:                  '3',   # Determines which version of the checklist is being used - default 3
    enable_recurrence:                  true,  # Enables recurrent audits, evaluations, and inspections - default on
    recurring_item_checklist:           false,
    non_recurring_item_checklist:       false,
    days_to_complete_instead_of_date:   false,
    daily_weekly_recurrence_frequecies: false,
  }

  HIERARCHY = {
    display_name: 'Safety Assurance',
    objects: {

      'Audit' => {
        title: 'Audit',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :findings,
          :responsible_user,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          title: { default: true },
          status: { default: true, on_newline: true, field: 'get_status' },
          created_by: { default: true },
          due_date: {default: true, on_newline: true },
          close_date: { default: true },
          responsible_user: { default: true, title: "Auditor" },
          approver: { default: true },
          department: {
            field: 'department', title: 'Auditing Department',
            num_cols: 6,  type: 'select', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          audit_department: {
            field: 'audit_department', title: 'Department being Audited',
            num_cols: 6,  type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          audit_type: {
            field: 'audit_type', title: 'Audit Type',
            num_cols: 6,  type: 'select', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['Audit Types']"
          },
          location: { default: true },
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
          vendor: { default: true },
          process: { default: true },
          supplier: {
            field: 'supplier', title: 'Internal/External/Supplier',
            num_cols: 6,  type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Suppliers']"
          },
          planned: { default: true },
          objective: { default: true },
          reference: { default: true },
          instruction: { default: true, title: 'Audit Instructions' },
          comment: { default: true, title: "Auditor's Comments", visible: 'show' },
          final_comment: { default: true, title: "Final Approver's Comments" },
          findings: {
            field: 'included_findings', title: 'Included Findings',
            num_cols: 6,  type: 'text', visible: 'index',
            required: false
          },
          verifications: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },

        actions: [
          #TOP
          *%i[delete override_status edit launch sign deid_pdf pdf viewer_access attach_in_message expand_all private_link],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen contact task cost finding comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[causes comments sras findings contacts costs tasks signatures extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },

      'Inspection' => {
        title: 'Inspection',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :responsible_user,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          title: { default: true },
          status: { default: true, on_newline: true, field: 'get_status' },
          created_by: { default: true },
          viewer_access: { default: true, on_newline: true },
          due_date: { default: true, on_newline: true },
          close_date: { default: true },
          responsible_user: { default: true, title: 'Lead Inspector' },
          approver: { default: true },
          department: {
            field: 'department', title: 'Inspection Department',
            num_cols: 6,  type: 'select', visible: 'index,form,show',
            required: false,      options: "CONFIG.custom_options['Departments']"
          },
          inspection_department: {
            field: 'inspection_department', title: 'Department being Inspected',
            num_cols: 6,  type: 'select', visible: 'form,show',
            required: false,      options: "CONFIG.custom_options['Departments']"
          },
          planned: { default: true },
          inspection_type: {
            field: 'inspection_type', title: 'Type',
            num_cols: 6,  type: 'text', visible: 'index,form,show',
            required: false, on_newline: true
          },
          location: { default: true },
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: 'form,show',
            required: false,      options: "CONFIG.custom_options['Station Codes']"
          },
          vendor: { default: true },
          process: { default: true },
          supplier: {
            field: 'supplier', title: 'Internal/External/Supplier',
            num_cols: 6,  type: 'select', visible: 'form,show',
            required: false,      options: "CONFIG.custom_options['Suppliers']"
          },
          objective: { default: true },
          reference: { default: true },
          instruction: { default: true, title: 'Inspection Instructions' },
          inspector_comment: {
            field: 'inspector_comment', title: "Lead Inspector's Comments",
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
          findings: {
            field: 'included_findings', title: 'Included Findings',
            num_cols: 6,  type: 'text', visible: 'index',
            required: false
          },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch sign deid_pdf pdf viewer_access attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen task cost contact finding comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[causes comments sras findings contacts costs tasks requirements signatures extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },

      'Evaluation' => {
        title: 'Evaluation',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :responsible_user,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          title: { default: true },
          status: { default: true, on_newline: true, field: 'get_status' },
          created_by: { default: true },
          viewer_access: { default: true, on_newline: true },
          due_date: { default: true, on_newline: true },
          close_date: { default: true },
          responsible_user: { default: true, title: 'Lead Evaluator' },
          approver: { default: true },
          department: {
            field: 'department', title: 'Evaluation Department',
            num_cols: 6, type: 'select', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          evaluation_department: {
            field: 'evaluation_department', title: 'Department being Evaluated',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          evaluation_type: {
            field: 'evaluation_type', title: 'Type',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['Evaluation Types']"
          },
          location: {
            field: 'location', title: 'Location',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6, type: 'datalist', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
          vendor: { default: true },
          process: { default: true },
          supplier: {
            field: 'supplier', title: 'Internal/External/Supplier',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Suppliers']"
          },
          planned: { default: true },
          objective: { default: true },
          reference: { default: true },
          instruction: { default: true, title: 'Evaluation Instructions' },
          evaluator_comment: {
            field: 'evaluator_comment', title: "Lead Evaluator's Comments",
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
          findings: {
            field: 'included_findings', title: 'Included Findings',
            num_cols: 6,  type: 'text', visible: 'index',
            required: false
          },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch sign deid_pdf pdf viewer_access attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen task cost contact finding comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[comments sras findings contacts costs tasks requirements signatures extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },

      'Investigation' => {
        title: 'Investigation',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :occurrences,
          :findings,
          :responsible_user,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          title: { default: true },
          get_source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          status: { default: true, on_newline: true, field: 'get_status' },
          created_by: { default: true },
          viewer_access: { default: true, on_newline: true },
          due_date: { default: true, on_newline: true },
          close_date: { default: true },
          responsible_user: { default: true, title: 'Investigator' },
          approver: { default: true },
          event_occurred: {
            field: 'event_occured', title: 'Date/Time When Event Occurred',
            num_cols: 6, type: 'datetime', visible: 'form,show',
            required: false
          },
          local_event_occurred: {
            field: 'local_event_occured', title: 'Local Time When Event Occurred',
            num_cols: 6, type: 'datetime', visible: 'form,show',
            required: false
          },
          inv_type: {
            field: 'inv_type', title: 'Investigation Type',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['Investigation Types']"
          },
          source: {
            field: 'source', title: 'Source',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Sources']"
          },
          ntsb: {
            field: 'ntsb', title: 'NTSB Reportable',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          safety_hazard: {
            field: 'safety_hazard', title: 'Safety Hazard',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          containment: {
            field: 'containment', title: 'Containment',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          notes: {
            field: 'notes', title: 'Notes',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          description: {
            field: 'description', title: 'Description of Event',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          investigator_comment: {
            field: 'investigator_comment', title: "Investigator's Comments",
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          occurrences: {default: true, title: (Investigation.find_top_level_section.label rescue nil)},
          occurrences_full: {default: true,
            visible: 'query',
            title: "Full #{Investigation.find_top_level_section.label rescue nil}"
          },
          verifications: { default: true },
          likelihood: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Likelihood" },
          severity: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Severity" },
          risk_factor: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Risk" },
          likelihood_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Risk" },
          findings: {
            field: 'included_findings', title: 'Included Findings',
            num_cols: 6,  type: 'text', visible: 'index',
            required: false
          },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch sign deid_pdf pdf view_parent viewer_access attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen recommendation contact task cost sms_action finding comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[comments occurrences source_of_input sras findings contacts costs tasks sms_actions recommendations signatures extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },

      'Finding' => {
        title: 'Finding',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
         preload: [
          :occurrences,
          :responsible_user,
          :approver,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          title: { default: true },
          status: { default: true, field: 'get_status', on_newline: true },
          get_source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          created_by: { default: true, on_newline: true },
          responsible_user: { default: true },
          approver: { default: true, visible: 'index,form,show,auto'  },
          due_date: { field: 'due_date', default: true },
          reference: { default: true, title: 'Reference or Requirement' },
          classification: {
            field: 'classification', title: 'Classification',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, on_newline: true, options: "CONFIG.custom_options['Classifications']"
          },
          department: {
            field: 'department', title: 'Department',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          regulatory_violation: {
            field: 'regulatory_violation', title: 'Regulatory Violation',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          policy_violation: {
            field: 'policy_violation', title: 'Policy Violation',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          safety: {
            field: 'safety', title: 'Safety Hazard',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          repeat: {
            field: 'repeat', title: 'Repeat Finding',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          authority: {
            field: 'authority', title: 'Authority',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          controls: {
            field: 'controls', title: 'Controls',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          interfaces: {
            field: 'interfaces', title: 'Interfaces',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          policy: {
            field: 'policy', title: 'Policy',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          procedures: {
            field: 'procedures', title: 'Procedure',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          process_measures: {
            field: 'process_measures', title: 'Process Measures',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          responsibility: {
            field: 'responsibility', title: 'Responsibility',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          immediate_action: {
            field: 'immediate_action', title: 'Immediate Action Required',
            num_cols: 12, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          action_taken: {
            field: 'action_taken', title: 'Immediate Action Taken',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          description: {
            field: 'description', title: 'Description of Finding',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          analysis_result: {
            field: 'analysis_result', title: 'Analysis Results',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          findings_comment: {
            field: 'findings_comment', title: "Responsible User's Comments",
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          other: {
            field: 'other', title: 'Other',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },

          occurrences: {default: true, title: (Finding.find_top_level_section.label rescue nil)},
          occurrences_full: {default: true,
            visible: 'query',
            title: "Full #{Finding.find_top_level_section.label rescue nil}"
          },
          verifications: { default: true },
          likelihood: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Likelihood" },
          severity: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Severity" },
          risk_factor: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Risk" },
          likelihood_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Risk" }
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_parent attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification recommendation sms_action approve_reject reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              if owner.owner.class.name == "ChecklistRow"
                true
              else
                DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op) &&
                (owner.immediate_action || owner.owner.status == 'Completed')
              end
            },
          },
        }),
        panels: %i[checklists comments occurrences sms_actions recommendations extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },

      'SmsAction' => {
        title: 'Corrective Action',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :responsible_user,
          :approver,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          title: { default: true },
          status: { default: true, field: 'get_status' },
          get_source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          created_by: { default: true },
          due_date: { default: true, field: 'due_date', on_newline: true },
          close_date: { default: true },
          responsible_user: { default: true },
          approver: { default: true, visible: 'index,form,show,auto', required: false },
          responsible_department: {
            field: 'responsible_department', title: 'Responsible Department',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          faa_approval: {
            field: 'faa_approval', title: 'Requires FAA Approval',
            num_cols: 6,  type: 'boolean_box', visible: 'none',
          },
          emp: {
            field: 'emp', title: 'Employee Corrective Action',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false, on_newline: true
          },
          dep: {
            field: 'dep', title: 'Company Corrective Action',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          immediate_action: {
            field: 'immediate_action', title: 'Immediate Action',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false, on_newline: true
          },
          immediate_action_comment: {
            field: 'immediate_action_comment', title: 'Immediate Action Comment',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          comprehensive_action: {
            field: 'comprehensive_action', title: 'Comprehensive Action',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
          comprehensive_action_comment: {
            field: 'comprehensive_action_comment', title: 'Comprehensive Action Comment',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          action_taken: {
            field: 'action_taken', title: 'Action Taken',
            num_cols: 12, type: 'datalist', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Actions Taken']"
          },
          description: {
            field: 'description', title: 'Description of Corrective Action',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          sms_actions_comment: {
            field: 'sms_actions_comment', title: "Responsible User's Comments",
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
          likelihood: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Likelihood" },
          severity: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Severity" },
          risk_factor: { default: true, title: "#{I18n.t("sa.risk.baseline.title")} Risk" },
          likelihood_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t("sa.risk.mitigated.title")} Risk" }
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_parent attach_in_message expand_all],
            #TODO: Complete Notices<=Notifications Update and add set_alert after view_parent
          #INLINE
          *%i[assign complete request_extension schedule_verification cost approve_reject reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op) &&
              (owner.immediate_action || (%w[Completed].include? owner.owner.status rescue true))
            },
          },
        }),
        panels: %i[causes comments costs extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc }
      },

      'Recommendation' => {
        title: 'Recommendation',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :responsible_user,
          :approver,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          title: { default: true },
          status: { default: true, field: 'get_status' },
          get_source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          created_by: { default: true },
          due_date: {
            field: 'due_date', title: 'Scheduled Response Date',
            num_cols: 6, type: 'date', visible: 'index,form,show',
            required: true, on_newline: true
          },
          close_date: { default: true, title: 'Actual Response Date' },
          responsible_user: { default: true, on_newline: true  },
          approver: { default: true },
          department: {
            field: 'department', title: 'Responsible Department',
            num_cols: 6, type: 'select', visible: 'index,form,show',
            required: false,  options: "CONFIG.custom_options['Departments']", on_newline: true
          },
          immediate_action: {
            field: 'immediate_action', title: 'Immediate Action Required',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false, on_newline: true
          },
          recommended_action: {
            field: 'recommended_action', title: 'Action',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false,  options: "CONFIG.custom_options['Actions Taken']", on_newline: true
          },
          description: {
            field: 'description', title: 'Description of Recommendation',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          recommendations_comment: {
            field: 'recommendations_comment', title: "Responsible User's Comments",
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_parent attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen comment]
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op) &&
              (owner.immediate_action || (%w[Completed].include? owner.owner.status rescue true))
            },
          },
        }),
        panels: %i[comments extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc }
      },

      'Checklist' => {
        title: 'Checklist',
      }
    },
    menu_items: {
      'Audits' => {
        title: 'Audits', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Audit'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) || 
                                   priv_check.call(Object.const_get('Audit'), user, 'new', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('Checklist'), user, 'add', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'audits_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Audit'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_audit_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Audit'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Recurring Audits', path: "recurrences_path(form_type: 'Audit')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] &&
                                       priv_check.call(Object.const_get('Audit'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true) &&
                                       priv_check.call(Object.const_get('Audit'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New Recurring Audits', path: "new_recurrence_path(form_type: 'Audit')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] &&
                                       priv_check.call(Object.const_get('Audit'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true) &&
                                       priv_check.call(Object.const_get('Audit'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Start Checklist', path: 'select_checklists_raw_checklists_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Checklist'), user, 'add', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Inspections' => {
        title: 'Inspections', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Inspection'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('Inspection'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'inspections_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Inspection'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_inspection_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Inspection'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Recurring Inspections', path: "recurrences_path(form_type: 'Inspection')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] &&
                                       priv_check.call(Object.const_get('Inspection'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) &&
                                       priv_check.call(Object.const_get('Inspection'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New Recurring Inspections', path: "new_recurrence_path(form_type: 'Inspection')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] &&
                                       priv_check.call(Object.const_get('Inspection'), user, 'new', CONFIG::GENERAL[:global_admin_default], true) &&
                                       priv_check.call(Object.const_get('Inspection'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Evaluations' => {
        title: 'Evaluations', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Evaluation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('Evaluation'), user, 'new', CONFIG::GENERAL[:global_admin_default], true) },
        subMenu: [
          {title: 'All', path: 'evaluations_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Evaluation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_evaluation_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Evaluation'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Recurring Evaluations', path: "recurrences_path(form_type: 'Evaluation')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] &&
                                       priv_check.call(Object.const_get('Evaluation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) &&
                                       priv_check.call(Object.const_get('Evaluation'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New Recurring Evaluations', path: "new_recurrence_path(form_type: 'Evaluation')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] &&
                                       priv_check.call(Object.const_get('Evaluation'), user, 'new', CONFIG::GENERAL[:global_admin_default], true) &&
                                       priv_check.call(Object.const_get('Evaluation'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Investigations' => {
        title: 'Investigations', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('Investigation'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'investigations_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_investigation_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Findings' => {
        title: 'Findings', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'findings_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Audits', path: 'findings_path(status: "New", :type=>"Audit")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Inspections', path: 'findings_path(status: "New", :type=>"Inspection")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Evaluations', path: 'findings_path(status: "New", :type=>"Evaluation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Investigations', path: 'findings_path(status: "New", :type=>"Investigation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Corrective Actions' => {
        title: 'Corrective Actions', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('SmsAction'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'sms_actions_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Findings', path: 'sms_actions_path(status: "New", :type=>"Finding")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Investigations', path: 'sms_actions_path(status: "New", :type=>"Investigation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_sms_action_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Recommendations' => {
        title: 'Recommendations', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Recommendation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'recommendations_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Recommendation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Findings', path: 'recommendations_path(status: "New", :type=>"Finding")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Recommendation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Investigations', path: 'recommendations_path(status: "New", :type=>"Investigation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Recommendation'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
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
