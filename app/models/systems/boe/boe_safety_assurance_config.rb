class BOESafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:          '1',
    # Airline-Specific Features:
  })

end
