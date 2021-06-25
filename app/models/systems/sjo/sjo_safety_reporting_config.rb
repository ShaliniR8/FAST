class SJOSafetyReportingConfig < DefaultSafetyReportingConfig
  
  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge( {
    menu_items: {
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| false},
        subMenu: [
          {title: 'All', path: 'faa_reports_path',
            display: proc{|user:,**op| true}},
          {title: 'New', path: 'new_faa_report_path',
            display: proc{|user:,**op| true}},
        ]
      },
    }
  })


end
