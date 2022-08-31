class DemoSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    enable_orm:                  true,
    submission_corrective_action_root_cause:    false,
    enable_external_email:     false,
    show_pdf_column_scoreboard: true,
  })

end
