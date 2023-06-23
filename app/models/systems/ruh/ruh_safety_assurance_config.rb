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
    }
  })

end
