class RJETSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:                  '3',
    days_to_complete_instead_of_date:   true,
  })


  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
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
