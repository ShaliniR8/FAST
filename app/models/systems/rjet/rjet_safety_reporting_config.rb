class RJETSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # Airline-Specific Features:
    attach_pdf_submission:           'ided',      # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
    enable_external_email:           true
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Record' => {
        fields: {
          likelihood: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Likelihood" },
          severity: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Severity" },
          risk_factor: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk" },

          likelihood_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Likelihood" },
          severity_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Severity" },
          risk_factor_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk" },
        }
      },

      'Report' => {
        fields: {
          likelihood: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Likelihood" },
          severity: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Severity" },
          risk_factor: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Baseline']} Risk",
            visible: 'index,meeting_form'
          },
          likelihood_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Likelihood" },
          severity_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Severity" },
          risk_factor_after: { default: true, title: "#{CONFIG::MATRIX_INFO[:terminology]['Mitigate']} Risk",
            visible: 'index,meeting_form'
          },
        }
      },
    }
  })

end
