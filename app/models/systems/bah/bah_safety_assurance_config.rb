class BAHSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    daily_weekly_recurrence_frequecies: true,
  })

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Investigation' => {
        fields: {
          local_event_occurred: {
            field: 'local_event_occured', title: 'Time when investigation is launched',
            num_cols: 6, type: 'datetime', visible: 'form,show',
            required: false
          },
          ntsb: {
            field: 'ntsb', title: 'NTSB Reportable',
            num_cols: 6, type: 'boolean_box', visible: '',
            required: false
          },
          safety_hazard: {
            field: 'safety_hazard', title: 'Safety Hazard',
            num_cols: 6, type: 'boolean_box', visible: '',
            required: false
          },
          containment: {
            field: 'containment', title: 'Containment',
            num_cols: 12, type: 'textarea', visible: '',
            required: false
          },
        }
      },
      'Audit' => {
        fields: {
          audit_department: {
            options: "CONFIG.custom_options['Operator/Organization']"
          },
          supplier: {
            visible: '',
          },
          vendor: {
            visible: '',
          },
          process: {
            visible: ''
          },
          station_code: {
            visible: '',
          },
        },
        actions: {
          contact: {
            access: proc { false },
          },
          cost: {
            access: proc { false },
          },
          task: {
            access: proc { false },
          }
        },
        panels: {
          contact: {
            access: proc { false },
          },
          cost: {
            access: proc { false },
          },
          task: {
            access: proc { false },
          }
        },
      },
      'SmsAction' => {
        fields: {
          responsible_department: {
            options: "CONFIG.custom_options['Operator/Organization']"
          },
          emp: {
            visible: ''
          },
          dep: {
            visible: ''
          },
          immediate_action: {
            visible: ''
          },
          comprehensive_action: {
            visible: ''
          },
          comprehensive_action_comment: {
            visible: ''
          },
        }
      },
      'Finding' => {
        fields: {
          department: {
            options: "CONFIG.custom_options['Operator/Organization']"
          }
        }
      }
    }
  })
end
