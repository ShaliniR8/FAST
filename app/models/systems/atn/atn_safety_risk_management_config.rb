class ATNSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig
  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({
    enable_risk_register:     false,
  })

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects:{
      'Sra' => {
        fields: {
          regulatory_compliances_panel_start: {
            field: 'compliances', title: 'Apparent Violations',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          compliances: {
            field: 'compliances', title: 'Apparent Violations',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Regulatory Compliances']"
          },
          other_compliance: {
            field: 'other_compliance', title: 'Other Apparent Violations',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          compliances_comment: {
            field: 'compliances_comment', title: 'Apparent Violations Comments',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
        }
      }
    }
  })
end
