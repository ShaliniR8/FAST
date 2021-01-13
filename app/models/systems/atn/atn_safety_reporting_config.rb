class ATNSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_time_zone:            false,
    # Airline-Specific Features:
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
