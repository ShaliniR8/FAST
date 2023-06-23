class RUHSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Audit' => {
        fields: {
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: '',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
        }
      },
      'Inspection' => {
        fields: {
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: '',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
        }
      },
      'Evaluation' => {
        fields: {
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: '',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
        }
      },
    }
  })

end
