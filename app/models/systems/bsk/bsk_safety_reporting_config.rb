class BSKSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    template_nested_fields:             true,
    # Airline-Specific Features:
    observation_phases_trend:           true,
  })

  OBSERVATION_PHASES = [
    "Observation Phase",
    "Condition",
    "Threat", "Sub Threat",
    "Error", "Sub Error",
    "Human Factor", "Comment"]

end
