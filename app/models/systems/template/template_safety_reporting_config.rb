class TemplateSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:

    # Airline-Specific Features:
  })

  HIERARCHY = DefaultSafetyReportingConfig::GENERAL.deep_merge({
  })
end
