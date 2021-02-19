class DemoConfig < DefaultConfig

  # Used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  # Used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = ['ASAP', 'SMS']

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'ProSafeT Demo',
    time_zone:                    'Pacific Time (US & Canada)',

    # SYSTEM CONFIGS
    enable_mailer:                false,
    has_mobile_app:               true,
    track_log:                    true,

    # Third Party Integrations:
    integrations: ['mitre', 'eccairs'],

    # SYSTEM-WIDE FORM CONFIGS
    allow_reopen_report:          false,
    configurable_risk_matrices:   true,
    shared_links:                 true,
    drop_down_risk_selection:     false,

    # TO BE REMOVED:
    allow_set_alert:              true,
    has_extension:                true,
    has_verification:             true,
  })

  MATRIX_INFO = DefaultConfig::MATRIX_INFO.deep_merge({
    severity_table: {
      row_header: ['5','4','3','2','1'],
      severity_table_dict: {
        0 => "5",
        1 => "4",
        2 => "3",
        3 => "2",
        4 => "1",
      },
    },
    probability_table: {
      column_header: ['A','B','C','D','E'],
      probability_table_dict: {
        0 => "A",
        1 => "B",
        2 => "C",
        3 => "D",
        4 => "E",
      },
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
      red:       {rating: "HIGH",     cells: "A4, A3, B4",     description: "Unacceptable"                 },
      yellow:    {rating: "MODERATE", cells: "A2, B2, C4",     description: "Acceptable with Mitigation"   },
      limegreen: {rating: "LOW",      cells: "A1, B2, C3, D4", description: "Acceptable"                   },
    },
  })

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                           => 'ProSafeT',
    'Region'                         => 'Pacific',
    'ASAP MOU Holder Name'           => 'ProSafeT',
    'ASAP MOU Holder FAA Designator' => 'ProSafeT'
  })

end
