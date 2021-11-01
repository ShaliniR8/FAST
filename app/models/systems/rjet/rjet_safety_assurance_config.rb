class RJETSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:                  '3',
    non_recurring_item_checklist:       true,
    days_to_complete_instead_of_date:   true,
    daily_weekly_recurrence_frequecies: true,
  })


  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Audit' => {
        fields: {
          cause_label: {
            field: 'cause_label',
            title: "#{CONFIG::CAUSE_LABEL} Label",
            visible: 'query',
            required: false
          },
          cause_value: {
            field: 'cause_value',
            title: "#{CONFIG::CAUSE_LABEL} Value",
            visible: 'query',
            required: false
          },
        }
      },
      'Inspection' => {
        fields: {
          cause_label: {
            field: 'cause_label',
            title: "#{CONFIG::CAUSE_LABEL} Label",
            visible: 'query',
            required: false
          },
          cause_value: {
            field: 'cause_value',
            title: "#{CONFIG::CAUSE_LABEL} Value",
            visible: 'query',
            required: false
          },
        }
      },
      'Investigation' => {
        fields: {
          likelihood: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Likelihood" },
          severity: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Severity" },
          risk_factor: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk" },
          likelihood_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Likelihood" },
          severity_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Severity" },
          risk_factor_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk" },
        }
      },

      'Finding' => {
        fields: {
          likelihood: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Likelihood" },
          severity: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Severity" },
          risk_factor: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk" },
          likelihood_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Likelihood" },
          severity_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Severity" },
          risk_factor_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk" }
        }
      },

      'SmsAction' => {
        fields: {
          likelihood: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Likelihood" },
          severity: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Severity" },
          risk_factor: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk" },
          likelihood_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Likelihood" },
          severity_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Severity" },
          risk_factor_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk" }
        }
      },
    }
  })

end
