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

    }
  })
end
