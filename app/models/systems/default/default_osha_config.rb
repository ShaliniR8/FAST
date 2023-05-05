class DefaultOshaConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them or copy the template configs
    # All configs inherit from their Default counterparts, then overload the default values when needed


  GENERAL = {
  }


  HIERARCHY = {
    display_name: 'OSHA / OJI',
    objects: {
      'OshaSubmission' => {
        title: 'OSHA Submission',
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
      'OshaRecord' => {
        title: 'OSHA Report',
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
        panels: %i[
        ].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
    },
    menu_items: {
      'Submissions' => {
        title: 'Submissions', path: '#',
        display: proc{|user:,**op|
          priv_check.call(Object.const_get('Submission'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
          user.get_all_submitter_templates.size > 0
        },
        subMenu: [
          {title: 'All', path: 'osha_submissions_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'In Progress', path: 'incomplete_submissions_path(type: "OSHA")',
            # display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
            display: proc{|user:,**op| user.get_all_submitter_templates.size > 0}},
          {title: 'New', path: 'new_osha_submission_path',
            # display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
            display: proc{|user:,**op| user.get_all_submitter_templates.size > 0}},
        ]
      },
      'Reports' => {
        title: 'Reports', path: 'osha_records_path(status: "New")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Record'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}
      },
      'OSHA Reports' => {
        title: 'OSHA 300 Reports', path: 'osha_300_osha_records_path',
        display: proc{|user:,**op| user.has_access('osha_reports', 'index', admin: CONFIG::GENERAL[:global_admin_default]) }
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
