class ATNSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_time_zone:            false,
    # Airline-Specific Features:
  })


end
