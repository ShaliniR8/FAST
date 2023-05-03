class MAFSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects:{
      'Hazard' => {
        fields: {
          departments: {
            field: 'departments', title: 'Program',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: true, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          }
        }
      },
      'RiskControl' => {
        fields: {
          departments: {
            field: 'departments', title: 'Program',
            num_cols: 6, type: 'select', visible: 'form,index,show',
            required: true, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          },
        }
      }
    }
  })

end
