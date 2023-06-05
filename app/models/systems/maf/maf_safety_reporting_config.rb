class MAFSafetyReportingConfig < DefaultSafetyReportingConfig

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects: {
      'Report' => {
        fields: {
          event_type: {
            field: 'event_type', title: 'Program', num_cols: 6, type: 'select',
            visible: 'index,form,show', required: true,
            options: "CONFIG::EMPLOYEE_GROUPS.keys"
          }
        }
      },
      'CorrectiveAction' => {
        fields: {
          department: {
            field: 'department', title: 'Program',
            num_cols: 6,  type: 'select', visible: 'form,show,index',
            required: true, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          },
        }
      }
    },
    menu_items: {
      'Submissions' => {
        subMenu: [
          {title: 'All', path: 'submissions_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Submission'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Draft', path: 'incomplete_submissions_path',
            display: proc{|user:,**op| user.get_all_submitter_templates.size > 0}},
          {title: 'New', path: 'new_submission_path',
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
    }
  })

end
