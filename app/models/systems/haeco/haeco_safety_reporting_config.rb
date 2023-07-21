class HAECOSafetyReportingConfig < DefaultSafetyReportingConfig

  HIERARCHY = {
    display_name: 'ASAP',
    display_workflow_diagram_module: true,
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
        print_panels: %w[risk_matrix occurrences corrective_actions records]
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
          response: {
            field: 'response', title: 'Title',
            num_cols: 6, type: 'text', visible: 'index,form,show',
            required: true
          },
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
          responsible_user: { default: true, on_newline: true }, # for form and show
          approver: { default: true },
          faa_approval: {
            field: 'faa_approval', title: 'Requires FAA Approval',
            num_cols: 6,  type: 'boolean_box', visible: 'none',
          },
          department: {
            field: 'department', title: 'Classification',
            num_cols: 6,  type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Classification']"
          },
          company: {
            field: 'company', title: 'Company Corrective Action',
            num_cols: 6,  type: 'boolean', visible: '',
            required: false, on_newline: true # for form and show
          },
          employee: {
            field: 'employee', title: 'Employee Corrective Action',
            num_cols: 6,  type: 'boolean', visible: '',
            required: false
          },
          bimmediate_action: {
            field: 'bimmediate_action', title: 'Immediate Action',
            num_cols: 6,  type: 'boolean_box', visible: '',
            required: false
          },
          immediate_action: {
            field: 'immediate_action', title: 'Findings & References',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          bcomprehensive_action: {
            field: 'bcomprehensive_action', title: 'Comprehensive Action',
            num_cols: 6,  type: 'boolean_box', visible: '',
            required: false, on_newline: true
          },
          description: { default: true, title: 'Description of Corrective Action', type: 'textarea', visible: 'index,form,show' },
          comprehensive_action: {
            field: 'comprehensive_action', title: 'Description of Preventive Action',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          action: {
            field: 'action', title: 'Action Taken',
            num_cols: 12,  type: 'datalist', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['Actions List for Corrective Actions']",
            on_newline: true # for form and show
          },
          corrective_actions_comment: {
            field: 'corrective_actions_comment', title: "Responsible User's Comments",
            num_cols: 12, type: 'textarea', visible: 'show',
            required: false
          },
          occurrences: {default: true, title: "Root Causes", visible: 'index'},
          final_comment: { default: true, title: "Final Approver's Comments" },
          verifications: { default: true },
        }.reduce({}) { |acc,(key,data)|
          acc[key] = (data[:default] ? DICTIONARY::META_DATA[key].merge(data) : data); acc
        },
        panels: %i[occurrences
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
        panels: %i[included_reports participants attachments transaction_log
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      }
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
        ]
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
        ]
      },
    }
  }

end
