class SCXSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:      false,
    enable_dual_report:       false,
    submission_time_zone:     true,
    default_submission_time_zone:               'Central Time (US & Canada)',

    matrix_carry_over:        true,
    share_meeting_agendas:    false,
    # Airline-Specific Features:
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
            num_cols: 4, type: 'text', visible: 'index,form,meeting_form,show',
            required: true, on_newline: true
          },
          event_station: {
            field: 'event_station', title: 'Event Station',
            num_cols: 4, type: 'select', options: "CONFIG.custom_options['Station Codes']", visible: 'index,form,meeting_form,show',
          },
          event_date: {
            default: true, title: 'Event Date',
            num_cols: 4, type: 'date', visible: 'index,form,meeting_form,show',
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
        actions: {
          pdf: {
            access: proc { |owner:,user:,**op|
              # Requested only admins can use normal pdf function 11/8/2019 by Stephanie Gabert
              super_proc('Report',:pdf).call(owner:owner,user:user,**op) && user.admin?
            },
          },
          meeting_ready: {
            access: proc { |owner:,user:,**op|
              # Requested unavailable until root cause analysis 10/2019 by Stephanie Gabert
              super_proc('Report',:pdf).call(owner:owner,user:user,**op) && owner.root_causes.present?
            },
          },
          close: {
            access: proc { |owner:,user:,**op|
              # Requested unavailable until root cause analysis 10/2019 by Stephanie Gabert
              super_proc('Report',:pdf).call(owner:owner,user:user,**op) && owner.root_causes.present?
            },
          },
        },
      },
    },
  })

end
