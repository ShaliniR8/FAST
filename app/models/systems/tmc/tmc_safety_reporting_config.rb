class TMCSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # Airline-Specific Features:
    allow_event_reuse: false, # Disable adding Events to multiple meetings - default on
  })
end
