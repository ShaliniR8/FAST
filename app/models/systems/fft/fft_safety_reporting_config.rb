class FFTSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:              true,
    enable_dual_report:               true,
    submission_time_zone:             true,
    submission_description_required:  true,
    configurable_agenda_dispositions: true,
    attach_pdf_submission:            true,
    # Airline-Specific Features:
  })


end
