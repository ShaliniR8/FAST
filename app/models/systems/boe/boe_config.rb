class BOEConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                            'Boeing Executive Flight Operations',
    time_zone:                       'Central Time (US & Canada)',

    # SYSTEM CONFIGS
    base_risk_matrix:                false,
    has_root_causes:                 false,

    # SYSTEM-WIDE FORM CONFIGS

  })

  MATRIX_INFO = DefaultConfig::MATRIX_INFO.deep_merge({
    severity_table: {
      row_header: ['5','4','3','2','1'],
    },
    probability_table: {
      column_header: ['A','B','C','D','E'],
    },
    risk_table: {
      row_header: ['5','4','3','2','1'],
      column_header: ['A','B','C','D','E'],
      rows_color: [
        ['yellow','red','red','red','red'],
        ['yellow','yellow','red','red','red'],
        ['limegreen','yellow','yellow','yellow','red'],
        ['limegreen','limegreen','yellow','yellow','yellow'],
        ['limegreen','limegreen','limegreen','yellow','yellow']
      ],
    },
  }).merge({ # replace default risk_definitions with boe custom definitions
    risk_definitions: {
      red:       {rating: "High",     cells: "A4, A3, B4",     description: "Unacceptable"                 },
      yellow:    {rating: "Moderate", cells: "A2, B2, C4",     description: "Acceptable with Mitigation"   },
      limegreen: {rating: "Low",      cells: "A1, B2, C3, D4", description: "Acceptable"                   },
    },
  })

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'=>'ACE-FSDO-09',
    'Region'=>'Central',
    'ASAP MOU Holder Name'=>'Boeing',
    'ASAP MOU Holder FAA Designator'=>'BASE'
  })

  #BOE's Risk Matrix is used as the default, therefore you will find it defined in default_config.rb

end
