class RUHSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({
    enable_risk_register:     false,
  })

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects: {
      'Sra' => {
        fields: {
          sra_type: {
            field: 'sra_type', title: "Level of SRA",
            num_cols: 6, type: 'select', visible: 'show,form',
            required: false, options: CONFIG.custom_options['Level of SRA']
          },
          responsible_user: { title: 'Risk Leader' },
          approver: { title: 'SRA Approver' },
        }
      },
      'Hazard' => {
        fields: {
          title: {
            type: 'datalist', options: CONFIG.custom_options['Hazard Titles']
          },
          responsible_user: { title: 'Risk Leader' },
          approver: { title: 'SRA Approver' },
        }
      },

      'RiskControl' => {
        fields: {
          approver: { title: 'Risk Assessment Leader' },
        }
      }
    }
  })

end
