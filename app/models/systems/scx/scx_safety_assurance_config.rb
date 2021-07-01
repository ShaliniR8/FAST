class SCXSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    non_recurring_item_checklist:       true,
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
