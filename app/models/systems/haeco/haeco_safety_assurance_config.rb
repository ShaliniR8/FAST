class HAECOSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Audit' => {
        fields: {
          id: { visible: 'index' },
          uniq_custom_id: { num_cols: 6, field: 'uniq_custom_id', title: 'Custom ID', visible: 'index,show' },
          process: { title: 'Audit Rating' },
          supplier: { title: 'Aircraft Number', type: 'text' },
        },
      }
    }
  })

end
