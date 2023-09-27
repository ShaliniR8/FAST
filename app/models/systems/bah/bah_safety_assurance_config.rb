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
            num_cols: 6, type: 'boolean_box', visible: 'none',
            required: false
          },
          safety_hazard: {
            field: 'safety_hazard', title: 'Safety Hazard',
            num_cols: 6, type: 'boolean_box', visible: 'none',
            required: false
          },
          containment: {
            field: 'containment', title: 'Containment',
            num_cols: 12, type: 'textarea', visible: 'none',
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
            visible: 'none',
          },
          vendor: {
            visible: 'none',
          },
          process: {
            visible: 'none'
          },
          station_code: {
            visible: 'none',
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
            visible: 'none'
          },
          dep: {
            visible: 'none'
          },
          immediate_action: {
            visible: 'none'
          },
          comprehensive_action: {
            visible: 'none'
          },
          comprehensive_action_comment: {
            visible: 'none'
          },
          risk_factor: {
            visible: 'none'
          },
          risk_factor_after: {
            visible: 'none'
          }
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
