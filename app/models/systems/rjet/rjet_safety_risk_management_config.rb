class RJETSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({
    enable_risk_register:     false,
  })

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects:{
      'Hazard' => {
        fields: {
          likelihood: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Likelihood" },
          severity: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Severity" },
          risk_factor: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk" },
          risk_score: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk Score" },
          likelihood_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Likelihood" },
          severity_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Severity" },
          risk_factor_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk" },
          risk_score_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk Score" },
        }
      },

      'SafetyPlan' => {
        fields: {
          risk_factor: {
            field: 'risk_factor', title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk",
            num_cols: 12, type: 'select', visible: 'index,form,show',
            required: false, on_newline: true, options: "CONFIG.custom_options['Risk Factors']"
          },
          risk_factor_after: {
            field: 'risk_factor_after', title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk",
            num_cols: 6,  type: 'select', visible: 'index,eval,show',
            required: false,  options: "CONFIG.custom_options['Risk Factors']"
          },
        }
      },
    }
  })

end
