class SCXSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({

    risk_assess_sras:      true,
    one_page_sra:          true
  })

end
