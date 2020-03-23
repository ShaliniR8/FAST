class FFTSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:             true,
    enable_dual_report:              true,
    submission_time_zone:            true,
    submission_description_required: false,
    # Airline-Specific Features:
  })


end
