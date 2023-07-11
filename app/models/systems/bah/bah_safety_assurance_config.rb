class BAHSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    daily_weekly_recurrence_frequecies: true,
  })

end
