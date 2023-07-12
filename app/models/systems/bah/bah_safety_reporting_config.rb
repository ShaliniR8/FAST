class BAHSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_local_time_zone:       true
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    menu_items: {
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| false}
      },
    }
  })

end
