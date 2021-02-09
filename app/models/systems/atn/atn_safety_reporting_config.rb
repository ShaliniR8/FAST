class ATNSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_time_zone:            false,
    # Airline-Specific Features:
    attach_pdf_submission:           'none',      # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
  })


  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Submission' => {
        fields: {
          id: {
            default: true, field: 'get_matching_record_id',
          }
        }
      }
    }
  })

end
