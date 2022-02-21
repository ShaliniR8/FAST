class AJTSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    checklist_version:                  '3',
    recurring_item_checklist:           true,
    non_recurring_item_checklist:       true,
    days_to_complete_instead_of_date:   true,
    daily_weekly_recurrence_frequecies: true,
  })

end
