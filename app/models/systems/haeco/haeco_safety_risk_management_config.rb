class HAECOSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({
    enable_risk_register:  true,
  })

end
