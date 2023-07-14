class HAECOSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    display_workflow_diagram_module: true,
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
