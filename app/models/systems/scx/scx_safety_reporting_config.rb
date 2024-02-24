class SCXSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:      true,
    enable_dual_report:       false,
    submission_time_zone:     true,
    default_submission_time_zone:               'Central Time (US & Canada)',

    matrix_carry_over:        true,
    share_meeting_agendas:    false,
    show_pdf_column_scoreboard: true,
    add_corrective_action_in_meeting: true,
    # Airline-Specific Features:
    attach_pdf_submission:     'deid',
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Submission' => {
        actions: {
          pdf: {
            access: proc { |owner:,user:,**op|
              # Requested only admins can use normal pdf function 11/8/2019 by Stephanie Gabert
              super_proc('Submission',:pdf).call(owner:owner,user:user,**op) && user.admin?
            },
          },
        },
      },
      'Record' => {
        actions: {
          pdf: {
            access: proc { |owner:,user:,**op|
              # Requested only admins can use normal pdf function 11/8/2019 by Stephanie Gabert
              super_proc('Record',:pdf).call(owner:owner,user:user,**op) && user.admin?
            },
          },
        },
      },
      'Report' => {
        fields: {
          id: { default: true, visible: 'index,meeting_form,show' },
          status: { default: true, visible: 'index,meeting_form,show' },
          name: {
            field: 'name', title: 'Event Title',
            num_cols: 6, type: 'text', visible: 'index,form,meeting_form,show',
            required: true, on_newline: true
          },
          event_station: {
            field: 'event_station', title: 'Event Station',
            num_cols: 6, type: 'datalist', options: "CONFIG.custom_options['Station Codes']", visible: 'index,form,meeting_form,show',
          },
          operation_type: {
            field: 'operation_type', title: 'Operation Type',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Operation Type']"
          },
          event_date: {
            default: true, title: 'Event Date',
            num_cols: 6, type: 'date', visible: 'index,form,meeting_form,show',
            required: true
          },
          reports: {
            field: 'included_reports', title: 'Included Reports',
            num_cols: 6, type: 'text', visible: 'index,meeting_form',
            required: false, on_newline: true
          },
          event_label: {
            field: 'event_label', title: 'Event Type',
            num_cols: 6, type: 'select', visible: 'event_summary',
            required: false,  options: "CONFIG.custom_options['Event Types']"
          },
          venue: {
            field: 'venue', title: 'Venue',
            num_cols: 6, type: 'select', visible: 'event_summary',
            required: false,  options: "CONFIG.custom_options['Event Venues']"
          },
          icao: {
            field: 'icao', title: 'ICAO',
            num_cols: 6, type: 'text', visible: 'event_summary',
            required: false
          },
          event_description: {
            field: 'narrative', title: 'Event Description',
            num_cols: 12, type: 'textarea', visible: 'index,form,meeting_form,show',
            required: true
          },
          minutes: {
            field: 'minutes', title: 'Meeting Minutes',
            num_cols: 12, type: 'textarea', visible: 'show,form',
            required: false
          },
          eir: {
            field: 'eir', title: 'EIR Number',
            num_cols: 6, type: 'text', visible: 'asap',
            required: false
          },
          scoreboard: {
            field: 'scoreboard', title: 'Exclude from Scoreboard',
            num_cols: 6, type: 'boolean', visible: 'asap',
            required: false
          },
          asap: {
            field: 'asap', title: 'Accepted Into ASAP',
            num_cols: 6, type: 'boolean', visible: 'asap',
            required: true
          },
          sole: {
            field: 'sole', title: 'Sole Source',
            num_cols: 6, type: 'boolean', visible: 'asap',
            required: true
          },
          disposition: {
            field: 'disposition', title: 'Disposition',
            num_cols: 6, type: 'datalist', visible: 'asap',
            required: false,  options: "CONFIG.custom_options['Dispositions']"
          },
          company_disposition: {
            field: 'company_disposition', title: 'Company Disposition',
            num_cols: 6, type: 'datalist', visible: 'asap',
            required: false,  options: "CONFIG.custom_options['Company Dispositions']"
          },
          narrative: {
            field: 'narrative', title: 'Narrative',
            num_cols: 12, type: 'textarea', visible: 'asap',
            required: false
          },
          regulation: {
            field: 'regulation', title: 'Regulation',
            num_cols: 12, type: 'textarea', visible: 'asap',
            required: false
          },
          notes: {
            field: 'notes', title: 'Final Comment',
            num_cols: 12, type: 'textarea', visible: 'close',
            required: false
          },
          occurrences: {default: true, title: (Report.find_top_level_section.label rescue nil)},
          occurrences_full: {default: true,
            visible: 'query',
            title: "Full #{Report.find_top_level_section.label rescue nil}"},
          likelihood: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Likelihood" },
          severity: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Severity" },
          risk_factor: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Risk",
            visible: 'index,meeting_form'
          },
          likelihood_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Risk",
            visible: 'index,meeting_form'
          },
          minutes_agenda: {
            field: 'get_minutes_agenda', title: 'Meeting Minutes & Agendas',
            num_cols: 12, type: 'text', visible: 'meeting',
            required: false
          }, #Gets overridden in view- see included_events.html.erb
          additional_info: {
            field: 'additional_info', title: 'Attachments',
            num_cols: 12, type: 'text', visible: 'meeting_form,meeting',
            required: false
          },
          included_reports_types: {
            field: 'included_reports_types', title: 'Included Reports Types',
            num_cols: 12, type: 'checkbox', visible: 'query',
            required: false
          },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
      },
      'CorrectiveAction' => {
        title: 'Corrective Action',
        status: ['New', 'Assigned', 'Pending Approval', 'Completed', 'Overdue', 'All'],
        preload: [
          :responsible_user,
          :verifications,
          :extension_requests],
        fields: {
          id: { default: true },
          status: { default: true, type: 'select', options: CorrectiveAction.getStatusOptions },
          created_by: { default: true },
          recommendation: {
            field: 'recommendation', title: 'Is this only a recommendation',
            num_cols: 6,  type: 'boolean', visible: '',
            required: false
          },
          due_date: { default: true, field: 'due_date' },
          close_date: { default: true },
          opened_date: {
            field: 'opened_date', title: 'Date Opened',
            num_cols: 6,  type: 'date', visible: 'show',
            required: false
          },
          assigned_date: {
            field: 'assigned_date', title: 'Date Assigned',
            num_cols: 6,  type: 'date', visible: 'show',
            required: false
          },
          decision_date: {
            field: 'decision_date', title: 'Date Completed/Rejected',
            num_cols: 6,  type: 'date', visible: 'show',
            required: false
          },
          department: {
            field: 'department', title: 'Department',
            num_cols: 6,  type: 'select', visible: 'form,show',
            required: true, options: "CONFIG.custom_options['Departments']"
          },
          responsible_user: { default: true, on_newline: true }, # for form and show
          approver: { default: true },
          faa_approval: {
            field: 'faa_approval', title: 'Requires FAA Approval',
            num_cols: 6,  type: 'boolean_box', visible: 'none',
          },
          company: {
            field: 'company', title: 'Company Corrective Action',
            num_cols: 6,  type: 'boolean', visible: 'form,show',
            required: false, on_newline: true # for form and show
          },
          employee: {
            field: 'employee', title: 'Employee Corrective Action',
            num_cols: 6,  type: 'boolean', visible: 'form,show',
            required: false
          },
          bimmediate_action: {
            field: 'bimmediate_action', title: 'Immediate Action',
            num_cols: 2,  type: 'boolean', visible: '',
            required: false
          },
          immediate_action: {
            field: 'immediate_action', title: 'Immediate Action Detail',
            num_cols: 12, type: 'textarea', visible: '',
            required: false
          },
          bcomprehensive_action: {
            field: 'bcomprehensive_action', title: 'Comprehensive Action',
            num_cols: 2,  type: 'boolean', visible: '',
            required: false, on_newline: true
          },
          description: { default: true, title: 'Description', type: 'textarea', visible: 'index,form,show' },
          comprehensive_action: {
            field: 'comprehensive_action', title: 'Description of Preventive Action',
            num_cols: 12, type: 'textarea', visible: '',
            required: false
          },
          corrective_actions_comment: {
            field: 'corrective_actions_comment', title: "Comprehensive Action Detail",
            num_cols: 10, type: 'textarea', visible: 'show',
            required: false
          },
          action: {
            field: 'action', title: 'Action',
            num_cols: 6,  type: 'datalist', visible: 'index,form,show',
            required: true, options: "CONFIG.custom_options['Actions List for Corrective Actions']",
            on_newline: true # for form and show
          },
          response: {
            field: 'response', title: 'Response',
            num_cols: 12, type: 'textarea', visible: '',
            required: false
          },
          designee: {
            field: 'designee', title: 'Station',
            num_cols: 6, type: 'datalist', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        panels: %i[occurrences
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
    },
  })

end
