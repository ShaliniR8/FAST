class JUSSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:                  '2',

    # Airline-Specific Features:
  })

end
