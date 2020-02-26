class TrialSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    enable_orm:                         true,
    template_nested_fields:             true,

    # Airline-Specific Features:
  })

end
