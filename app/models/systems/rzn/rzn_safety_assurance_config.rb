class RZNSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:                  '3',
    non_recurring_item_checklist:       true,
    days_to_complete_instead_of_date:   true,
    daily_weekly_recurrence_frequecies: true,
  })

end
