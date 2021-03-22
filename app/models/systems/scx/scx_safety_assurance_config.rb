class SCXSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

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
