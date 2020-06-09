class ATNSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_time_zone:            true,
    # Airline-Specific Features:
  })


end
