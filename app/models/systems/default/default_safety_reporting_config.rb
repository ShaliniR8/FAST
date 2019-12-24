class DefaultSafetyReportingConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them or copy the template configs
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:
    enable_orm:               false,     # Enables ORM Reports - default off
    show_submitter_name:      true,      # Displays submitter names when access to show (admins will always see it)- default on
    submission_description:   true,      # Changes Character Limit or adds General Description - default on
    template_nested_fields:   false,     # WIP nested smart forms functionality - default off

    # Airline-Specific Features:
    observation_phases_trend: false,     # Specific Feature for BSK - default off
    event_summary:            false,     # Adds summary Tab for Events in Safety Reporting nav bar - default off
    event_tabulation:         false,     # Adds Tabulation Tab for Events in Safety Reporting nav bar - default off
  }

  OBSERVATION_PHASES = [
    'Observation Phase',
    'Condition',
    'Threat', 'Sub Threat',
    'Error', 'Sub Error',
    'Human Factor', 'Comment'
  ]

  HIERARCHY = {
    display_name: 'ASAP',
    objects: {

      'Submission' => {
        title: 'Submission',
        fields: {
          id: { default: true, field: 'get_id' },
          template: { default: true, title: 'Submission Type' },
          submitter: { default: true, visible: "admin#{GENERAL[:show_submitter_name] ? ',index,show' : ''}" },
          event_date: { default: true },
          description: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        actions: [
          #TOP
          *%i[delete pdf deid_pdf view_report attach_in_message message_submitter expand_all],
          #INLINE
          *%i[comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          delete: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:delete][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          pdf: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:pdf][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          deid_pdf: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:deid_pdf][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          view_report: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:view_report][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          comment: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:comment][:access].call(owner:owner,user:user,**op) &&
                (owner.user_id == user.id || user.has_access('submissions','admin',admin:true,strict:true))
            },
          },
        }),
        panels: %i[]
      },


      'Record' => {
        title: 'Report',
        fields: {
          id: { default: true, field: 'get_id' },
          status: { default: true },
          template: { default: true, title: 'Type' },
          submitter: { default: true, visible: "admin#{GENERAL[:show_submitter_name] ? ',index,show' : ''}" },
          viewer_access: { default: true, type: 'boolean', visible: 'index,show' },
          event_date: { default: true, visible: 'form,index,show' },
          root_causes_full: { default: true, title: "#{I18n.t("sr.report.root_cause.title")}" },
          root_causes: { default: true, title: "#{I18n.t("sr.report.root_cause.title")}",
            visible: CONFIG::GENERAL[:has_root_causes] ? 'index' : ''
          },
          description: { default: true, visible: 'form,index,show' },
          final_comment: { default: true },

          likelihood: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Likelihood" },
          severity: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Severity" },
          risk_factor: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Risk" },

          likelihood_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Risk" },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
      },

      'Report' => {
        title: 'Event',
        fields: {
          id: { default: true, visible: 'index,meeting_form,show' },
          status: { default: true, visible: 'index,meeting_form,show' },
          name: {
            field: 'name', title: 'Event Title',
            num_cols: 6, type: 'text', visible: 'index,form,meeting_form,show',
            required: true, on_newline: true
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
          root_causes_full: { default: true, title: "#{I18n.t("sr.event.root_cause.title")}" },
          root_causes: { default: true, title: "#{I18n.t("sr.event.root_cause.title")}",
            visible: CONFIG::GENERAL[:has_root_causes] ? 'index,meeting_form' : ''
          },
          event_label: {
            field: 'event_label', title: 'Event Type',
            num_cols: 6, type: 'select', visible: 'event_summary',
            required: false,  options: Report.get_custom_options('Event Types')
          },
          venue: {
            field: 'venue', title: 'Venue',
            num_cols: 6, type: 'select', visible: 'event_summary',
            required: false,  options: Report.get_custom_options('Event Venues')
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
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          eir: {
            field: 'eir', title: 'EIR Number',
            num_cols: 6, type: 'text', visible: 'close',
            required: false
          },
          scoreboard: {
            field: 'scoreboard', title: 'Exclude from Scoreboard',
            num_cols: 6, type: 'boolean', visible: 'close',
            required: true
          },
          asap: {
            field: 'asap', title: 'Accepted Into ASAP',
            num_cols: 6, type: 'boolean', visible: 'close',
            required: true
          },
          sole: {
            field: 'sole', title: 'Sole Source',
            num_cols: 6, type: 'boolean', visible: 'close',
            required: true
          },
          disposition: {
            field: 'disposition', title: 'Disposition',
            num_cols: 6, type: 'datalist', visible: 'close',
            required: false,  options: Report.get_custom_options('Dispositions')
          },
          company_disposition: {
            field: 'company_disposition', title: 'Company Disposition',
            num_cols: 6, type: 'datalist', visible: 'close',
            required: false,  options: Report.get_custom_options('Company Dispositions')
          },
          narrative: {
            field: 'narrative', title: 'Narrative',
            num_cols: 12, type: 'textarea', visible: 'close',
            required: false
          },
          regulation: {
            field: 'regulation', title: 'Regulation',
            num_cols: 12, type: 'textarea', visible: 'close',
            required: false
          },
          notes: {
            field: 'notes', title: 'Closing Notes',
            num_cols: 12, type: 'textarea', visible: 'close',
            required: false
          },
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
            field: 'additional_info', title: 'Has Attachments',
            num_cols: 12, type: 'text', visible: 'meeting_form,meeting',
            required: false
          },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
      },
      'CorrectiveAction' => {
        title: 'Corrective Action',
        fields: {
          id: { default: true },
          status: { default: true, type: 'select', options: CorrectiveAction.getStatusOptions },
          created_by: { default: true },
          recommendation: {
            field: 'recommendation', title: 'Is this only a recommendation',
            num_cols: 6,  type: 'boolean', visible: 'form,show',
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
            required: false, options: CorrectiveAction.departments
          },
          responsible_user: { default: true, on_newline: true }, # for form and show
          approver: { default: true },
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
            num_cols: 2,  type: 'boolean', visible: 'form,show',
            required: false
          },
          immediate_action: {
            field: 'immediate_action', title: 'Immediate Action Detail',
            num_cols: 10, type: 'text', visible: 'form,show',
            required: false
          },
          bcomprehensive_action: {
            field: 'bcomprehensive_action', title: 'Comprehensive Action',
            num_cols: 2,  type: 'boolean', visible: 'form,show',
            required: false, on_newline: true
          },
          comprehensive_action: {
            field: 'comprehensive_action', title: 'Comprehensive Action Detail',
            num_cols: 10, type: 'text', visible: 'form,show',
            required: false
          },
          action: {
            field: 'action', title: 'Action',
            num_cols: 6,  type: 'datalist', visible: 'index,form,show',
            required: false, options: CorrectiveAction.action_options, on_newline: true # for form and show
          },
          description: { default: true, title: 'Description', type: 'textarea', visible: 'index,form,show' },
          response: {
            field: 'response', title: 'Response',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          final_comment: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
      },
    }
  }



end
