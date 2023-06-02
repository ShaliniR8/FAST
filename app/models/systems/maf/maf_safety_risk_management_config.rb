class MAFSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects:{
      'Sra' => {
        fields: {
          departments_panel_start: {
            title: 'Affected Programs',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          departments: {
            field: 'departments', title: 'Affected Programs',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Departments']"
          },
          other_department: {
            field: 'other_department', title: 'Other Affected Programs',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          departments_comment: {
            field: 'departments_comment', title: 'Affected Programs Comments',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
          programs_panel_start: {
            title: 'Affected Processes/Systems',
            num_cols: 12, type: 'panel_start', visible: 'form,show'
          },
          programs: {
            field: 'programs', title: 'Affected Processes/Systems',
            num_cols: 12, type: 'checkbox', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Programs']"
          },
          other_program: {
            field: 'other_program', title: 'Other Processes/Systems',
            num_cols: 6, type: 'text', visible: 'form,show',
            required: false
          },
          programs_comment: {
            field: 'programs_comment', title: 'Affected Processes/Systems',
            num_cols: 12, type: 'textarea', visible: 'form,show',
            required: false
          },
        }
      },
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
