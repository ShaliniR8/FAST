class MAFSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects: {
      'Audit' => {
        fields: {
          department: {
            field: 'department', title: 'Auditing Program',
            num_cols: 6,  type: 'select', visible: '',
            required: false, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          },
          audit_department: {
            field: 'audit_department', title: 'Program being Audited',
            num_cols: 6,  type: 'select', visible: 'form,show,index',
            required: true, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          }
        }
      },
      'Evaluation' => {
        fields: {
          department: {
            field: 'department', title: 'Evaluation Program',
            num_cols: 6, type: 'select', visible: '',
            required: false, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          },
          evaluation_department: {
            field: 'evaluation_department', title: 'Program being Evaluated',
            num_cols: 6, type: 'select', visible: 'form,show,index',
            required: true, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          }
        }
      },
      'Finding' => {
        fields: {
          department: {
            field: 'department', title: 'Program',
            num_cols: 6, type: 'select', visible: 'index,form,show',
            required: true, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          }
        }
      },
      'Inspection' => {
        fields:{
          department: {
            field: 'department', title: 'Inspection Program',
            num_cols: 6,  type: 'select', visible: '',
            required: false,      options: "CONFIG::EMPLOYEE_GROUPS.keys"
          },
          inspection_department: {
            field: 'inspection_department', title: 'Program being Inspected',
            num_cols: 6,  type: 'select', visible: 'form,show,index',
            required: true,      options: "CONFIG::EMPLOYEE_GROUPS.keys"
          }
        }
      },
      'Investigation' => {
          fields: {
            department: {
              field: 'department', title: 'Program',
              num_cols: 6, type: 'select', visible: '',
              required: false,  options: "CONFIG::EMPLOYEE_GROUPS.keys"
            },
            ntsb: {
              field: 'ntsb', title: 'Regulator Reportable',
              num_cols: 6, type: 'boolean_box', visible: 'form,show',
              required: false
          }
        }
      },
      'Recommendation' => {
        fields:{
          department: {
            field: 'department', title: 'Responsible Program',
            num_cols: 6, type: 'select', visible: 'index,form,show',
            required: true,  options: "CONFIG::EMPLOYEE_GROUPS.keys", on_newline: true
          }
        }
      },
      'SmsAction' => {
        fields:{
          responsible_department: {
            field: 'responsible_department', title: 'Responsible Program',
            num_cols: 6, type: 'select', visible: 'form,show,index',
            required: true, options: "CONFIG::EMPLOYEE_GROUPS.keys"
          }
        }
      },
    }
  })

end
