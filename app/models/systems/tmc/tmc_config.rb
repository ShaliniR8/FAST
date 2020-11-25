class TMCConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Travel Management Company',
    time_zone:                          'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS

    # SYSTEM-WIDE FORM CONFIGS
    allow_reopen_forms:                false,
    has_root_causes:                   false,
    drop_down_risk_selection:          true,

  })

  MATRIX_INFO = DefaultConfig::MATRIX_INFO.deep_merge({
    risk_table: {
      column_header_name: 'LIKELIHOOD',

    }
  }).merge({ # replace default risk_definitions with tmc custom definitions
    risk_definitions: {
      '#60FF60' => {rating: 'Green - Acceptable',      cells: "A1, B2, C3, D4",        },
      yellow:      {rating: 'Yellow - Acceptable with mitigation', cells: "A2, B2, C4",},
      orange:      {rating: 'Orange - Unacceptable',     cells: "A4, A3, B4",          },
    },
  })

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'=>'ACE-FSDO-09',
    'Region'=>'Central',
    'ASAP MOU Holder Name'=>'Travel Management Company',
    'ASAP MOU Holder FAA Designator'=>'TMC'
  })


  # calculate_probability used .last instead of .min on the return

end
