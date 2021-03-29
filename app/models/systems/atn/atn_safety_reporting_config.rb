class ATNSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_time_zone:            false,
    # Airline-Specific Features:
    attach_pdf_submission:           'none',      # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
    match_submission_record_id:      true,
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
