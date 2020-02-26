class NAMSSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:

    # Airline-Specific Features:
  })

  OBSERVATION_PHASES = [
    'Observation Phase',
    'Condition',
    'Threat',
    'Error',
    'Human Factor',
    'Comment'
  ]


end
