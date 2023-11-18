class SBASafetyReportingConfig < DefaultSafetyReportingConfig
  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    menu_items: {
      "Submissions" => {
        subMenu: [
          {title: 'All', path: 'submissions_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'In Progress', path: 'incomplete_submissions_path',
            display: proc{|user:,**op| user.get_all_submitter_templates.size > 0}},
          {title: 'New', path: 'new_submission_path',
            display: proc{|user:,**op| user.get_all_submitter_templates.size > 0}},
          {title: 'ASAP Library', path: 'asap_library_submissions_path',
            display: proc{|user:,**op| false}},
          {title: 'ORMs', path: '#',  header: true,
            display: proc{|user:,**op| CONFIG.sr::GENERAL[:enable_orm]}},
          {title: 'All', path: 'orm_submissions_path',
            display: proc{|user:,**op| CONFIG.sr::GENERAL[:enable_orm]}},
          {title: 'New', path: 'new_orm_submission_path',
            display: proc{|user:,**op| CONFIG.sr::GENERAL[:enable_orm]}},
        ]
      },
      "FAA Reports" => {
        display: proc{|user:,**op| false}
      }
    }
  })

end
