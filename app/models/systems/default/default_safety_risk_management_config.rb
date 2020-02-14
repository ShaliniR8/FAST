class DefaultSafetyRiskManagementConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:

    # Airline-Specific Features:
  }


  HIERARCHY = {
    display_name: 'Safety Risk Management',
    objects: {

      'Sra' => {
        title: 'SRA',
        fields: {
          id: { default: true, field: 'get_id' },
          status: { default: true },
          source: {
            field: 'get_source', title: 'Source of Input',
            num_cols: 6, type: 'text', visible: 'index,show',
            required: false
          },
          title: { default: true, title: 'SRA Title', on_newline: true },
          type_of_change: {
            field: 'type_of_change', title: 'Type of Change',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: CONFIG.custom_options['SRA Type of Change']
          },
          system_task: {
            field: 'system_task', title: 'System/Task',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: CONFIG.custom_options['Systems/Tasks']
          },
          responsible_user: { default: true },
          reviewer: {
            field: 'reviewer_id', title: 'Quality Reviewer',
            num_cols: 6, type: 'user', visible: 'form,show',
            required: false
          },
          approver: { default: true },
          due_date: { default: true,
            field: 'due_date',
            required: false
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
            field: 'closing_comment', title: "Responsible User's Closing Comments",
            num_cols: 12, type: 'text', visible: 'show',
            required: false
          },
          reviewer_comment: {
            field: 'reviewer_comment', title: "Quality Reviewer's Closing Comments",
            num_cols: 12, type: 'text', visible: 'show',
            required: false
          },
          approver_comment: {
            field: 'approver_comment', title: "Final Approver's Closing Comments",
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
            required: false, options: CONFIG.custom_options['Departments']
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
            required: false, options: CONFIG.custom_options['Programs']
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
            required: false, options: CONFIG.custom_options['Manuals']
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
            required: false, options: CONFIG.custom_options['Regulatory Compliances']
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
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },

        actions: [
          #TOP
          *%i[delete override_status edit deid_pdf pdf view_meeting view_parent viewer_access attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject hazard reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[agendas comments hazards extension_requests verifications records attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'Hazard' => {
        title: 'Hazard',
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
            required: false, options: CONFIG.custom_options['Departments']
          },
          responsible_user: { default: true },
          approver: { default: true },
          due_date: { default: true,
            field: 'due_date',
            required: false
          },
          description: {
            field: 'description', title: 'Description',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          final_comment: { default: true },
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
          *%i[delete override_status edit deid_pdf pdf view_sra attach_in_message expand_all],
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
                priv_check.call(owner,user,'admin',true,true) ||
                op[:user_conds]
              form_confirmed && user_confirmed
            },
          },
        }),
        panels: %i[risk_assessment occurrences risk_controls comments extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'RiskControl' => {
        title: 'Risk Control',
        fields: {
          id: { default: true },
          status: { default: true },
          created_by: { default: true },
          title: { default: true },
          departments: {
            field: 'departments', title: 'Department',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: false, options: CONFIG.custom_options['Departments']
          },
          due_date: { default: true,
            field: 'due_date',
            required: false
          },
          follow_up_date: {
            field: 'follow_up_date', title: 'Date for Follow-Up/Monitor Plan',
            num_cols: 6, type: 'date', visible: 'form,show', required: false
          },
          responsible_user: { default: true },
          approver: { default: true,
            field: 'approver_id',
            visible: 'index,form,show'
          },
          control_type: {
            field: 'control_type', title: 'Type',
            num_cols: 6, type: 'datalist', visible: 'form,show',
            required: false, options: CONFIG.custom_options['Risk Control Types']
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
          final_comment: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete override_status edit deid_pdf pdf view_hazard attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen cost comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              form_confirmed = ['New', 'Open'].include? owner.status || op[:form_conds]
              user_confirmed = [owner.created_by_id, owner.approver_id].include?(user.id) ||
                priv_check.call(owner,user,'admin',true,true) ||
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
        panels: %i[costs comments extension_requests verifications attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'SafetyPlan' => {
        title: 'Safety Plan',
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
            required: false, on_newline: true, options: CONFIG.custom_options['Risk Factors']
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
          date_completed: {
            field: 'date_completed', title: 'Date Completed',
            num_cols: 6, type: 'date', visible: 'show,eval',
            required: false
          },
          result: {
            field: 'result', title: 'Result',
            num_cols: 6, type: 'select', visible: 'show,eval',
            required: false,  options: CONFIG.custom_options['Results']
          },
          risk_factor_after: {
            field: 'risk_factor_after', title: 'Mitigated Risk',
            num_cols: 6,  type: 'select', visible: 'index,eval,show',
            required: false,  options: CONFIG.custom_options['Risk Factors']
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
          *%i[complete_safety_plan evaluate reopen comment],
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
        panels: %i[comments attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'Meeting' => {
        title: 'Meeting',
        fields: {
          id: { default: true },
          status: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[],
          #INLINE
          *%i[],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[included_sras participants attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      }
    },
  }

end
