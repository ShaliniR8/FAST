class FFTSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:              true,
    enable_dual_report:               true,
    submission_time_zone:             true,
    submission_description_required:  true,
    configurable_agenda_dispositions: true,
    dropdown_event_title_list:        true,
    limit_reporting_title_length:     true,
    # Airline-Specific Features:
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Report' => {
        fields: {
          name: {
            field: 'name', title: 'Event Title',
            num_cols: 6, type: 'datalist', visible: 'index,form,meeting_form,show',
            required: true, on_newline: true, options: CONFIG.custom_options['Event Titles']
          },
          event_types: {
            field: 'event_type', title: 'Event Type',
            num_cols: 12, type: 'text', visible: 'query',
            required: false
          },
        },
        print_panels: %w[risk_matrix occurrences records ]
      }
    }
  })

end
