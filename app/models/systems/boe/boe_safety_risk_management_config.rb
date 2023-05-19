class BOESafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig
  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({
    enable_risk_register:     false,
  })
end
