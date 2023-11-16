class SBASafetyReportingConfig < DefaultSafetyReportingConfig
  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    menu_items: {
      "FAA Reports" => {
        display: proc{|user:,**op| false}
      }
    }
  })

end
