class JEDSafetyReportingConfig < DefaultSafetyReportingConfig

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    menu_items: {
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| false}
      },
    }
  })
end
