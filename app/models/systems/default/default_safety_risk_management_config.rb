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
            required: false, options: Sra.get_custom_options('SRA Type of Change')
          },
          system_task: {
            field: 'system_task', title: 'System/Task',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: Sra.get_custom_options('Systems/Tasks')
          },
          responsible_user: { default: true },
          reviewer: {
            field: 'reviewer_id', title: 'Quality Reviewer',
            num_cols: 6, type: 'user', visible: 'form,show',
            required: false
          },
          approver: { default: true },
          completion: { default: true,
            field: "scheduled_completion_date",
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
            required: false, options: Sra.get_custom_options('Departments')
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
            required: false, options: Sra.get_custom_options('Programs')
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
            required: false, options: Sra.get_custom_options('Manuals')
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
            title: 'Affected Regulatory Compliances',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          compliances: {
            field: 'compliances', title: 'Affected Regulatory Compliances',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: Sra.get_custom_options('Regulatory Compliances')
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
          *%i[assign complete approve_reject hazard reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[hazards agendas records occurrences comments attachments transaction_log
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
            field: 'departments', title: 'Affected Department',
            num_cols: 6, type: "select", visible: 'form,index,show',
            required: false, options: Hazard.get_custom_options('Departments')
          },
          description: {
            field: 'description', title: 'Description',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          root_causes_full: {
            field: 'get_root_causes_full', title: "#{I18n.t("srm.hazard.root_cause.title")}",
            type: 'list', visible: 'invisible'
          },
          root_causes: {
            field: 'get_root_causes', title: "#{I18n.t("srm.hazard.root_cause.title")}",
            type: 'list', visible: 'index'
          },
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
          *%i[delete override_status edit deid_pdf pdf view_sra expand_all],
          #INLINE
          *%i[reject complete risk_control reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[risk_assessment root_causes occurrences descriptions risk_controls comments attachments transaction_log
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
            field: 'departments', title: 'Affected Department',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: false, options: RiskControl.get_custom_options('Departments')
          },

          completion: { default: true,
            field: "scheduled_completion_date",
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
            required: false, options: RiskControl.get_custom_options('Risk Control Types')
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
          *%i[assign complete add_cost approve_reject reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[descriptions costs occurrences comments attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
      'SafetyPlan' => {
        title: 'Safety Plan',
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
        panels: %i[evaluation occurrences attachments transaction_log
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
