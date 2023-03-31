class RJETSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # Airline-Specific Features:
    attach_pdf_submission:           'ided',      # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
    enable_external_email:           true,
    show_event_title_in_query:       false,
    show_title_deid_pdf:             false
  })

  ASAP_LIBRARY_FIELD_NAMES = {
    departure_names:                ["Departure Airport"],
    arrival_names:                  ["Destination Airport"],
    actual_names:                   ["Diversion Airport"]
  }

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Record' => {
        fields: {
          asap: {
            field: 'asap', title: 'Accepted Into ASAP',
            num_cols: 6, type: 'boolean', visible: 'close',
            required: false
          },
          narrative: {
            field: 'narrative', title: 'Synopsis',
            num_cols: 12, type: 'textarea', visible: 'close',
            required: false
          },
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
          asap: {
            field: 'asap', title: 'Accepted Into ASAP',
            num_cols: 6, type: 'boolean', visible: 'asap',
            required: false
          },
          narrative: {
            field: 'narrative', title: 'Synopsis',
            num_cols: 12, type: 'textarea', visible: 'asap',
            required: false
          },
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
