class NAMSSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:                  '3',
    enable_recurrence:                  false,

    # Airline-Specific Features:
  })

end
