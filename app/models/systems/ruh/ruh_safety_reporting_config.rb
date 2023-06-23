class RUHSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:              true,
    enable_dual_report:               true,
    submission_time_zone:             true,
    submission_description_required:  true,
    configurable_agenda_dispositions: true,
    # Airline-Specific Features:
    hide_faa_reports:                 true,
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects: {
      'CorrectiveAction' => {
          fields: {
            response: {
              visible: '',
          },
        }
      },
    }
  })
end
