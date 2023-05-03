class MAFSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects:{
      'Hazard' => {
        fields: {
          departments: {
            field: 'departments', title: 'Program',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          }
        }
      },
      'RiskControl' => {
        fields: {
          departments: {
            field: 'departments', title: 'Program',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
        }
      }
    }
  })

end
