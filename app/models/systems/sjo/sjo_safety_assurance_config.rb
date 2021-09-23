class SJOSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    non_recurring_item_checklist:       true,
    days_to_complete_instead_of_date:   true,
    daily_weekly_recurrence_frequecies: true,
  })

end
