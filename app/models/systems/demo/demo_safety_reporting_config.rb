class DemoSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    enable_orm:                  true,
    template_nested_fields:      true,
    dropdown_event_title_list:   true,
    submission_corrective_action_root_cause:    true,
    enable_external_email:     true,
    show_pdf_column_scoreboard: true,
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
        },
      }
    }
  })

end
