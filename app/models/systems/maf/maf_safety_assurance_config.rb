class MAFSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects: {
      'Investigation' => {
          fields: {
            ntsb: {
              field: 'ntsb', title: 'Regulator Reportable',
              num_cols: 6, type: 'boolean_box', visible: 'form,show',
              required: false
          }
        }
      },
    }
  })

end
