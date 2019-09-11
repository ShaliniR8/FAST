class DemoSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    enable_orm:                  true,
    template_nested_fields:      true,
  })

end
