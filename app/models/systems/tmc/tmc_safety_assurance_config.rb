class TMCSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:                  '1',
    enable_recurrence:                  false,

    # Airline-Specific Features:
  })

end
