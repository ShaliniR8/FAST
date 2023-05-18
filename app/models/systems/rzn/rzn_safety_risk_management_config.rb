class RZNSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({
    enable_risk_register:  true,
  })

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects: {
      'RiskControl' => {
        fields: {
          risk_category: {
            field: 'risk_category', title: 'Risk Category',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Risk Categories']"
          }
        }
      }
    }
  })

end
