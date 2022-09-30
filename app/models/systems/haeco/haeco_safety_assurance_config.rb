class HAECOSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Audit' => {
        fields: {
          process: { title: 'Audit Rating' },
          supplier: { title: 'Aircraft Number', type: 'text' },
        },
      }
    }
  })

end
