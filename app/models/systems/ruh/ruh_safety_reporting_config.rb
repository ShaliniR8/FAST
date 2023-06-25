class RUHSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:              true,
    enable_dual_report:               true,
    submission_time_zone:             true,
    submission_description_required:  true,
    configurable_agenda_dispositions: true,
    # Airline-Specific Features:
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects: {
      'CorrectiveAction' => {
          fields: {
            response: {
              visible: '',
          },
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
        ]
      },
      'Corrective Actions' => {
        title: 'Corrective Actions', path: 'corrective_actions_path(status: "New")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('CorrectiveAction'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}
      },
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| false},
        subMenu: [
          {title: 'All', path: 'faa_reports_path',
            display: proc{|user:,**op| false}},
          {title: 'New', path: 'new_faa_report_path',
            display: proc{|user:,**op| false }},
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
  })
end
