class DefaultSafetyReportingConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them or copy the template configs
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:
    enable_orm:                       false,     # Enables ORM Reports - default off
    show_submitter_name:              true,      # Displays submitter names when access to show (admins will always see it)- default on
    show_event_title_in_query:        true,
    submission_description:           true,      # Changes Character Limit or adds General Description - default on
    submission_description_required:  true,
    submission_time_zone:             false,
    submission_utc_time_zone:         false,
    submission_local_time_zone:       false,
    template_nested_fields:           true,      # nested smart forms functionality - default ON
    enable_dual_report:               true,
    matrix_carry_over:                false,
    configurable_agenda_dispositions: false,
    share_meeting_agendas:            true,

    # Airline-Specific Features:
    attach_pdf_submission:     'ided',    # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
    observation_phases_trend:  false,     # Specific Feature for BSK - default off
    event_summary:             false,     # Adds summary Tab for Events in Safety Reporting nav bar - default off
    event_tabulation:          false,     # Adds Tabulation Tab for Events in Safety Reporting nav bar - default off
    allow_event_reuse:         true,      # Specific Feature for TMC: Toggle adding Event to multiple meetings - default on
    dropdown_event_title_list: false,     # Specific Feature for FFT - default off
    match_submission_record_id: false,    # Display Record's ID on Submission pages (currently applied: ATN)
    submission_corrective_action_root_cause:    false,    # Flag for corrective action and root causes at submission level
    enable_external_email:     false,      # Enables bcc email to external email IDs from message submitter
    show_pdf_column_scoreboard: false,
    limit_reporting_title_length:   false,
    show_title_deid_pdf:        true,      # Show the title of De-Id PDF. True by default but some carriers do not want this because users put identifying info on the title
    send_notifier_email_to_submitter:        true, # Submitter will get a notifier email with or without PDF if this is set to true. So submitter will get 2 emails
    display_workflow_diagram:                 true, # Display workflow diagrams in the instruction panels in this module
  }

  OBSERVATION_PHASES = [
    'Observation Phase',
    'Condition',
    'Threat', 'Sub Threat',
    'Error', 'Sub Error',
    'Human Factor', 'Comment'
  ]

  ASAP_LIBRARY_FIELD_NAMES = {
    departure_names:                ["Departure Airport"],
    arrival_names:                  ["Scheduled Arrival Airport"],
    actual_names:                   ["Landing Airport"]
  }

  HIERARCHY = {
    display_name: 'ASAP',
    objects: {

      'Submission' => {
        title: 'Submission',
        status: ['All'],
        preload: [:created_by, :template, :submission_fields],
        fields: {
          id: { default: true, field: 'get_id' },
          template: { default: true, title: 'Submission Type' },
          submitter: { default: true, visible: "admin,query,index" },
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
                (owner.user_id == user.id || user.has_access('submissions','admin',admin:CONFIG::GENERAL[:global_admin_default],strict:true))
            },
          },
        }),
        panels: %i[causes].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
        workflow_images: {
          "new"=> "/images/SR_Workflow/Submission.png",
          "continue"=> "/images/SR_Workflow/Submission.png",
        }
      },


      'Record' => {
        title: 'Report',
        status: ['New', 'Open', 'Linked', 'Closed', 'All'],
        preload: [:created_by, :template, :occurrences, :record_fields],
        fields: {
          id: { default: true, field: 'get_id', visible: 'index,query,show,library' },
          status: { default: true, visible: 'index,query,show,library' },
          template: { default: true, title: 'Type', visible: 'index,query,show,library' },
          submitter: { default: true, visible: "admin,query,index" },
          viewer_access: { default: true, type: 'boolean', visible: 'index,show,library' },
          event_date: { default: true, visible: 'form,index,show' },
          description: { default: true, visible: 'form,index,show' },
          eir: {
            field: 'eir', title: 'EIR Number',
            num_cols: 6, type: 'text', visible: 'close',
            required: false
          },
          scoreboard: {
            field: 'scoreboard', title: 'Exclude from ASAP Library',
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
          regulatory_violation: {
            field: 'regulatory_violation', title: 'Regulatory Violation',
            num_cols: 6, type: 'boolean', visible: 'close',
            required: false
          },
          disposition: {
            field: 'disposition', title: 'Disposition',
            num_cols: 6, type: 'datalist', visible: 'close,query',
            required: false,  options: "CONFIG.custom_options['Dispositions']"
          },
          company_disposition: {
            field: 'company_disposition', title: 'Company Disposition',
            num_cols: 6, type: 'datalist', visible: 'close',
            required: false,  options: "CONFIG.custom_options['Company Dispositions']"
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
          final_comment: {
            default: true,
            field: 'final_comment', title: 'Final Comment',
            num_cols: 12, type: 'textarea', visible: 'close,show',
            required: false
          },
          # notes: {
          #   field: 'notes', title: 'Closing Notes',
          #   num_cols: 12, type: 'textarea', visible: 'close',
          #   required: false
          # },
          occurrences: {default: true, title: (Record.find_top_level_section.label rescue nil)},
          occurrences_full: {default: true,
            visible: 'query',
            title: "Full #{Record.find_top_level_section.label rescue nil}"},
          likelihood: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Likelihood" },
          severity: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Severity" },
          risk_factor: { default: true, title: "#{I18n.t("sr.risk.baseline.title")} Risk" },

          likelihood_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Likelihood" },
          severity_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Severity" },
          risk_factor_after: { default: true, title: "#{I18n.t("sr.risk.mitigated.title")} Risk" },
          get_additional_info_html: {
            field: 'get_additional_info_html', title: 'Additional Info',
            num_cols: 12, type: 'text', visible: 'index',
            required: false
          }
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        panels: %i[causes occurrences sras investigations
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
        workflow_images: {
          "new"=> "/images/SR_Workflow/Report_New.png",
          "open"=> "/images/SR_Workflow/Report_Open.png",
          "linked"=> "/images/SR_Workflow/Report_Linked.png",
          "closed"=> "/images/SR_Workflow/Report_Closed.png",
        }
      },

      'Report' => {
        title: 'Event',
        status: ['New', 'Meeting Ready', 'Under Review', 'Closed', 'All'],
        preload: [ :attachments, :occurrences, :records => [:created_by, :report] ],
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
            num_cols: 4, type: 'text', visible: '',
          },
          event_date: {
            default: true, title: 'Event Date',
            num_cols: 6, type: 'date', visible: 'index,form,meeting_form,show',
            required: true
          },
          event_type: {
            field: 'event_type', title: 'Department', num_cols: 6, type: 'text', visible: '',
            options: "CONFIG.custom_options['Departments']"
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
            field: 'scoreboard', title: 'Exclude from ASAP Library',
            num_cols: 6, type: 'boolean', visible: 'asap',
            required: true
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
          regulatory_violation: {
            field: 'regulatory_violation', title: 'Regulatory Violation',
            num_cols: 6, type: 'boolean', visible: 'asap',
            required: false
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
            num_cols: 12, type: 'textarea', visible: 'close,asap',
            required: false
          },
          occurrences: {default: true, title: (Report.find_top_level_section.label rescue '')},
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
        panels: %i[causes occurrences sras investigations
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
        print_panels: %w[risk_matrix occurrences corrective_actions records],
        workflow_images: {
          "new"=> "/images/SR_Workflow/Event_New.png",
          "under review"=> "/images/SR_Workflow/Event_UnderReview.png",
          "meeting ready"=> "/images/SR_Workflow/Event_MeetingReady.png",
          "closed"=> "/images/SR_Workflow/Event_Closed.png",
        }
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
            required: false, options: "CONFIG.custom_options['Departments']"
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
            num_cols: 2,  type: 'boolean', visible: 'form,show',
            required: false
          },
          immediate_action: {
            field: 'immediate_action', title: 'Immediate Action Detail',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          bcomprehensive_action: {
            field: 'bcomprehensive_action', title: 'Comprehensive Action',
            num_cols: 2,  type: 'boolean', visible: 'form,show',
            required: false, on_newline: true
          },
          description: { default: true, title: 'Description', type: 'textarea', visible: 'index,form,show' },
          comprehensive_action: {
            field: 'comprehensive_action', title: 'Description of Preventive Action',
            num_cols: 12, type: 'textarea', visible: 'form,show',
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
            required: false, options: "CONFIG.custom_options['Actions List for Corrective Actions']",
            on_newline: true # for form and show
          },
          response: {
            field: 'response', title: 'Response',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        panels: %i[occurrences
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
        workflow_images: {
          "new"=> "/images/SR_Workflow/CorrectiveAction_New.png",
          "pending approval"=> "/images/SR_Workflow/CorrectiveAction_PendingApproval.png",
          "assigned"=> "/images/SR_Workflow/CorrectiveAction_Assigned.png",
          "completed"=> "/images/SR_Workflow/CorrectiveAction_Completed.png",
          "completed, verification required"=> "/images/SR_Workflow/CorrectiveAction_VerificationRequired.png"
        }
      },
    },
    menu_items: {
      'Submissions' => {
        title: 'Submissions', path: '#',
        display: proc{|user:,**op|
          priv_check.call(Object.const_get('Submission'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
          user.get_all_submitter_templates.size > 0 ||
          priv_check.call(Object.const_get('Submission'), user, 'library', CONFIG::GENERAL[:global_admin_default], true)
        },
        subMenu: [
          {title: 'All', path: 'submissions_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'In Progress', path: 'incomplete_submissions_path',
            # display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
            display: proc{|user:,**op| user.get_all_submitter_templates.size > 0}},
          {title: 'New', path: 'new_submission_path',
            # display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
            display: proc{|user:,**op| user.get_all_submitter_templates.size > 0}},
          {title: 'ASAP Library', path: 'asap_library_submissions_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'library', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'ORMs', path: '#',  header: true,
            display: proc{|user:,**op| CONFIG.sr::GENERAL[:enable_orm]}},
          {title: 'All', path: 'orm_submissions_path',
            display: proc{|user:,**op| CONFIG.sr::GENERAL[:enable_orm]}},
          {title: 'New', path: 'new_orm_submission_path',
            display: proc{|user:,**op| CONFIG.sr::GENERAL[:enable_orm]}},
        ]
      },
      'Reports' => {
        title: 'Reports', path: 'records_path(status: "New")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Record'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}
      },
      'Events' => {
        title: 'Events',  path: '#',
        display: proc{|user:,**op|
          priv_check.call(Object.const_get('Report'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)
        },
        subMenu: [
          {title: 'All', path: 'reports_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Report'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Summary', path: 'summary_reports_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Report'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true) && CONFIG.sr::GENERAL[:event_summary]}},
          {title: 'Tabulation', path: 'tabulation_reports_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Report'), user, 'admin', CONFIG::GENERAL[:global_admin_default], true) && CONFIG.sr::GENERAL[:event_tabulation]}},
        ]
      },
      'Meetings' => {
        title: 'Meetings', path: '#',
        display: proc{|user:,**op|
          priv_check.call(Object.const_get('Meeting'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
          priv_check.call(Object.const_get('Meeting'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)
        },
        subMenu: [
          {title: 'All', path: 'meetings_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Meeting'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_meeting_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Meeting'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ],
        workflow_images: {
          "new"=> "/images/SR_Workflow/Meeting_Open.png",
          "open"=> "/images/SR_Workflow/Meeting_Open.png",
          "closed"=> "/images/SR_Workflow/Meeting_Closed.png",
        }
      },
      'Corrective Actions' => {
        title: 'Corrective Actions', path: 'corrective_actions_path(status: "New")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('CorrectiveAction'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}
      },
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| user.has_access('faa_reports', 'index', admin: CONFIG::GENERAL[:global_admin_default]) ||
                                   user.has_access('faa_reports', 'new', admin: CONFIG::GENERAL[:global_admin_default])},
        subMenu: [
          {title: 'All', path: 'faa_reports_path',
            display: proc{|user:,**op| user.has_access('faa_reports', 'index', admin: CONFIG::GENERAL[:global_admin_default])}},
          {title: 'New', path: 'new_faa_report_path',
            display: proc{|user:,**op| user.has_access('faa_reports', 'new', admin: CONFIG::GENERAL[:global_admin_default])}},
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
        ],
        workflow_images: {
          "Submission"              => "/images/SR_Workflow/QC_Submission.png",
          "Record"                  => "/images/SR_Workflow/QC_Report.png", ## This is Report
          "Report"                  => "/images/SR_Workflow/QC_Event.png", ## This is event
          "CorrectiveAction"        => "/images/SR_Workflow/QC_CorrectiveAction.png",
          "default"                 => "/images/SR_Workflow/QC_default.png"
        }
      },
    }
  }

end
