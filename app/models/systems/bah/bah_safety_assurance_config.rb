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
      'SmsAction' => {
        fields: {
          emp: {
            field: 'emp', title: 'Employee Corrective Action',
            num_cols: 6, type: 'boolean_box', visible: '',
            required: false, on_newline: true
          },
          dep: {
            field: 'dep', title: 'Company Corrective Action',
            num_cols: 6, type: 'boolean_box', visible: '',
            required: false
          },
          immediate_action: {
            field: 'immediate_action', title: 'Immediate Action',
            num_cols: 6, type: 'boolean_box', visible: '',
            required: false, on_newline: true
          },
          comprehensive_action: {
            field: 'comprehensive_action', title: 'Comprehensive Action',
            num_cols: 6, type: 'boolean_box', visible: '',
            required: false
          },
          comprehensive_action_comment: {
            field: 'comprehensive_action_comment', title: 'Comprehensive Action Comment',
            num_cols: 12, type: 'textarea', visible: '',
            required: false
          },
        }
      }
    }
  })
end
