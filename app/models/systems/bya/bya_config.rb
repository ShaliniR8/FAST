class BYAConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Berry Aviation',
    time_zone:                    'Central Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:                             true,
    # enable_sso:                                 true,
    # login_option:                               'dual',
    # csv_user_import:                            true,
    # asrs_integration:                           true,

    has_pdf_footer:                             false,
    advanced_checklist_data_type:               true,
    checklist_query:                            true,

    # TO BE REMOVED
    base_risk_matrix:             false,
    has_verification:             true,
    sms_im_visibility:            false,
    safety_promotion_visibility:  true,
    global_admin_default:         false,
  })


  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Initial Risk',
      mitigate_btn: 'Mitigate Risk',
      'Baseline' => 'Baseline',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY',

      orientation: :horizontal,
      direction: :left,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      column_header_name: 'SEVERITY',
      column_header: ['1 - Negligible', '2 - Minor', '3 - Major', '4 - Hazardous', '5 - Catastrophic'],
      row_header_name: 'CLASS',
      row_header: [
        'SELECT SEVERITY'
      ],
      rows: [
        [ #System/  Program/ Policy
          'Negligible', 'Minor', 'Major', 'Hazardous', 'Catastrophic'
        ]

      ] #End of rows
    },

    severity_table_dict: {
      0 => '1',
      1 => '2',
      2 => '3',
      3 => '4',
      4 => '5'
    },

    probability_table: {
      title: 'LIKELIHOOD',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: 'PROBABILITY',
      row_header: ['5 - Frequent', '4 - Occasional', '3 - Remote', '2 - Improbable', '1 - Extremely Improbable'],
      column_header_name: 'CRITERIA',
      column_header: [''],
      rows: [
        [ #1
          "Frequent"
        ],
        [ #2
          "Occasional"
        ],
        [ #3
          "Remote"
        ],
        [ #4
          "Improbable"
        ],
        [ #5
          "Extremely Improbable"
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => '4',
      1 => '3',
      2 => '2',
      3 => '1',
      4 => '0'
    },

    risk_table: {
      title: 'RISK ASSESSMENT MATRIX',

      size: 'col-xs-6',
      title_style: 'matrixTitle',
      main_header_style: 'matrixMainHeader',
      header_style: 'matrixHeader',
      cell_name: 'risk_td',
      cell_style: 'bold',

      # maps severity / likelihood attribute to position on table
      severity_pos: 'column',
      likelihood_pos: 'row',

      column_header_name: 'SEVERITY',
      column_header: ['1 - Negligible', '2 - Minor', '3 - Major', '4 - Hazardous', '5 - Catastrophic'],
      row_header_name: 'LIKELIHOOD',
      row_header: ['5 - Frequent', '4 - Occasional', '3 - Remote', '2 - Improbable', '1 - Extremely Improbable'],

      rows_color: [
        ["yellow",          "yellow",         "red",            "red",            "red"],
        ["mediumseagreen",  "yellow",         "yellow",         "red",            "red"],
        ["mediumseagreen",  "mediumseagreen", "yellow",         "yellow",         "red"],
        ["mediumseagreen",  "mediumseagreen", "mediumseagreen", "yellow",         "yellow"],
        ["mediumseagreen",  "mediumseagreen", "mediumseagreen", "mediumseagreen", "yellow"],
      ],

      rows: [
        ["Yellow - Acceptable with Mitigation",  "Yellow - Acceptable with Mitigation",   "Red- Unacceptable",                     "Red- Unacceptable",                     "Red- Unacceptable"],
        ["Green - Acceptable",                   "Yellow - Acceptable with Mitigation",   "Yellow - Acceptable with Mitigation",   "Red- Unacceptable",                     "Red- Unacceptable"],
        ["Green - Acceptable",                   "Green - Acceptable",                    "Yellow - Acceptable with Mitigation",   "Yellow - Acceptable with Mitigation",   "Red- Unacceptable"],
        ["Green - Acceptable",                   "Green - Acceptable",                    "Green - Acceptable",                    "Yellow - Acceptable with Mitigation",   "Yellow - Acceptable with Mitigation"],
        ["Green - Acceptable",                   "Green - Acceptable",                    "Green - Acceptable",                    "Green - Acceptable",                    "Yellow - Acceptable with Mitigation"],
      ],
    },

    risk_table_index: {
      "High" => 'red',
      "Moderate" => 'yellow',
      "Low" => 'mediumseagreen'
    },

    risk_table_dict: {
      red:            "High",
      yellow:         "Moderate",
      mediumseagreen: "Low",
    },

    risk_definitions: {
      red:              { rating: 'High',      cells: 'A/1, A/2, and B/1',                        description: 'Unacceptable' },
      yellow:           { rating: 'Moderate',  cells: 'A/4, B/3, and D/1',                        description: 'Acceptable with Mitigation' },
      mediumseagreen:   { rating: 'Low',       cells: 'A/5, B/5, C/4, C/5, D/3, D/4, and D/5',    description: 'Acceptable' }
    },
  }

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                           => 'ProSafeT',
    'Region'                         => 'Pacific',
    'ASAP MOU Holder Name'           => 'ProSafeT',
    'ASAP MOU Holder FAA Designator' => 'ProSafeT'
  })

end
