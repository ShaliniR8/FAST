class SCXSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({

    risk_assess_sras:         true,
    one_page_sra:             true,
    enable_sra_viewer_access: true,
    enable_risk_register:     false,
  })

end
