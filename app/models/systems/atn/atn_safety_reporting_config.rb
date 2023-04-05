class ATNSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_time_zone:            false,
    submission_local_time_zone:      true,
    # Airline-Specific Features:
    attach_pdf_submission:           'none',      # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
    match_submission_record_id:      true,
    enable_external_email:           true,
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
