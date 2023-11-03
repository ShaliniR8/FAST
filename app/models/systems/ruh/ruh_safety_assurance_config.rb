class RUHSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL =  DefaultSafetyAssuranceConfig::GENERAL.merge({
    daily_weekly_recurrence_frequecies: true
  })

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Audit' => {
        fields: {
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: '',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
          location: { default: true, type: 'select', options: "CONFIG.custom_options['Locations']" },
        }
      },
      'Inspection' => {
        fields: {
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: '',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
          location: { default: true, type: 'select', options: "CONFIG.custom_options['Locations']" },
        }
      },
      'Evaluation' => {
        fields: {
          station_code: {
            field: 'station_code', title: 'Station Code',
            num_cols: 6,  type: 'datalist', visible: '',
            required: false, options: "CONFIG.custom_options['Station Codes']"
          },
          location: {
            field: 'location', title: 'Location',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Locations']"
          },
        }
      },
      'Investigation' => {
        fields: {
          ntsb: {
            field: 'ntsb', title: 'AIB Reportable',
            num_cols: 6, type: 'boolean_box', visible: 'form,show',
            required: false
          },
        }
      },
    }
  })

end
