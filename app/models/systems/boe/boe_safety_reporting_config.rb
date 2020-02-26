class BOESafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:                false,
    # Airline-Specific Features:
    event_summary:                      true,
    event_tabulation:                   true,

  })

end
