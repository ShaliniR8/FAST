class AJTSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects:{
      'Sra' => {
        fields: {
          type_of_change: {
            field: 'type_of_change', title: 'SRM Triggers',
            num_cols: 6, type: 'datalist', visible: 'index,form,show',
            required: false, options: "CONFIG.custom_options['SRA Type of Change']"
          },
        }
      },
    }
  })

end
