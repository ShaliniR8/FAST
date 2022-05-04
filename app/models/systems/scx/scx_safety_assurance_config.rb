class SCXSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    recurring_item_checklist:           true,
    non_recurring_item_checklist:       true,
    days_to_complete_instead_of_date:   true,
    daily_weekly_recurrence_frequecies: true,
  })

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects: {
      'Investigation' => {
          fields: {
            ntsb: {
              field: 'ntsb', title: 'Regulatory Violation',
              num_cols: 6, type: 'boolean_box', visible: 'form,show',
              required: false
          }
        }
      },
    }
  })

end
