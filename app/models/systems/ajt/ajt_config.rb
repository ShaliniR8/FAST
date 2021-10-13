class AJTConfig < DefaultConfig

  # Used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  # Used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = ['ASAP', 'SMS']

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Amerijet International Airlines',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:               false,
    track_log:                    true,

    # SYSTEM-WIDE FORM CONFIGS
    drop_down_risk_selection:     false,
    sms_im_visibility:            false,
  })

  # MATRIX_INFO = DefaultConfig::MATRIX_INFO.deep_merge({
  #   severity_table: {
  #     row_header: ['5','4','3','2','1'],
  #     severity_table_dict: {
  #       0 => "5",
  #       1 => "4",
  #       2 => "3",
  #       3 => "2",
  #       4 => "1",
  #     },
  #   },
  #   probability_table: {
  #     column_header: ['A','B','C','D','E'],
  #     probability_table_dict: {
  #       0 => "A",
  #       1 => "B",
  #       2 => "C",
  #       3 => "D",
  #       4 => "E",
  #     },
  #   },
  #   risk_table: {
  #     row_header: ['5','4','3','2','1'],
  #     column_header: ['A','B','C','D','E'],
  #     rows_color: [
  #       ['yellow','red','red','red','red'],
  #       ['yellow','yellow','red','red','red'],
  #       ['limegreen','yellow','yellow','yellow','red'],
  #       ['limegreen','limegreen','yellow','yellow','yellow'],
  #       ['limegreen','limegreen','limegreen','yellow','yellow']
  #     ],
  #   },
  # }).merge({ # replace default risk_definitions with boe custom definitions
  #   risk_definitions: {
  #     red:       {rating: "HIGH",     cells: "A4, A3, B4",     description: "Unacceptable"                 },
  #     yellow:    {rating: "MODERATE", cells: "A2, B2, C4",     description: "Acceptable with Mitigation"   },
  #     limegreen: {rating: "LOW",      cells: "A1, B2, C3, D4", description: "Acceptable"                   },
  #   },
  # })

  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Initial Risk',
      mitigate_btn: 'Mitigated Risk',
      'Baseline' => 'Initial',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY TABLE',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'SEVERITY',
      row_header: ['5&nbsp;Catastrophic','4&nbsp;Critical','3&nbsp;Major','2&nbsp;Minor','1&nbsp;Negligible','0&nbsp;No Safety Implication'],
      column_header_name: 'CATEGORY',
      column_header: ['Injury or Illness','Aircraft, Facility or Terrorism Event','Operational Compliance, Performance','Damage, Fine or Loss of Revenue','Corporate Image','Damage to the Environment'],
      rows: [        
        [ # Catastrophic
          "Multiple fatalities",
          "Total loss of aircraft or facility",
          "Potential threat to Operating Certificate",
          "Damage, fines or loss of revenue >$5M",
          "Potential for Corporate failure, permanent impact on business system-wide",
          "Massive environmental effect"
        ],
        [ # Critical
          "Single fatality or multiple overnight hospital admissions",
          "NTSB accident or substantial loss of affected property",
          "Regulatory /Company policy and/or procedure deviation with a critical impact on safety",
          "Damage, fines or loss of revenue >$1M- $5M",
          "Adverse effect on Corporate image, significant impact on a region",
          "Critical environmental effect"
        ],
        [ # Moderate
          "Single overnight hospitalization",
          "NTSB incident or accident, partial loss of a facility or a credible security threat",
          "Regulatory /Company policy and/or procedure deviation with major reduction in safety margin",
          "Damage, fines or loss of revenue >$250K - $1M",
          "Major effect on Corporate image, isolated to a single location",
          "Contained effect to the environment"
        ],
        [ # Minor
          "Medical treatment beyond first aid",
          "NTSB incident or minor property damage",
          "Regulatory/Company policy and/or procedure deviation with minor safety implication",
          "Damage, fines or loss of revenue >$15K - $250K",
          "Minor effect on Corporate image, isolated effect that is easily reversible",
          "Minor environmental effect"
        ],
        [ # Negligible
          "First Aid treatment",
          "Negligible incident or damage with extremely limited effect on safety",
          "Regulatory/Company policy and/or procedure deviation with limited safety implication",
          "Damage, fines or loss of revenue <$15K",
          "Negligible effect on Corporate image, little to no potential for negative impact on the AS/QX brand",
          "Negligible environmental effect"
        ],
        [ # No Safety Implication
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication"
        ],
      ]
    },

    severity_table_dict: {
      0 => '0 - No Safety Implication',
      1 => '1 - Negligible',
      2 => '2 - Minor',
      3 => '3 - Moderate',
      4 => '4 - Critical',
      5 => '5 - Catastrophic'
    },

    probability_table: {
      title: 'LIKELIHOOD TABLE',

      orientation: :horizontal,
      direction: :right,
      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: '',
      row_header: [''],
      column_header_name: 'LIKELIHOOD',
      column_header: ['1&nbsp;Extremely Improbable','2&nbsp;Improbable','3&nbsp;Remote','4&nbsp;Occasional','5&nbsp;Frequent','6&nbsp;Repetitive'],
      rows: [
        [
          "<b>Once in 10 + years at AS/QX</b>",
          "<b>Once in 2-10 years at AS/QX</b>",
          "<b>Once in < 2 years at AS/QX</b>",
          "<b>2-11 times per year at AS/QX</b>",
          "<b>1-3 times per month at AS/QX</b>",
          "<b>4 + times per month at AS/QX</b>"
        ]
      ]
    },

    probability_table_dict: {
      1 => '1 - Extremely Improbable',
      2 => '2 - Improbable',
      3 => '3 - Remote',
      4 => '4 - Occasional',
      5 => '5 - Frequent',
      6 => '6 - Repetitive'
    },

    risk_table: {
      title: 'RISK ASSESSMENT MATRIX',

      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'matrixTitle',
      main_header_style: 'matrixMainHeader',
      header_style: 'matrixHeader',
      cell_name: 'risk_td',
      cell_style: 'bold',

      # maps severity / likelihood attribute to position on table
      severity_pos: 'row',
      likelihood_pos: 'column',

      row_header_name: 'SEVERITY',
      row_header: ['5&nbsp;Catastrophic','4&nbsp;Critical','3&nbsp;Major','2&nbsp;Minor','1&nbsp;Negligible','0&nbsp;No Safety Implication'],
      column_header_name: 'LIKELIHOOD',
      column_header: ['1&nbsp;Extremely Improbable','2&nbsp;Improbable','3&nbsp;Remote','4&nbsp;Occasional','5&nbsp;Frequent','6&nbsp;Repetitive'],
      rows: [        
        ['4',     '4',     '5',    '5',      '5',    '5' ],
        ['3',     '3',     '4',    '5',      '5',    '5' ],
        ['2',     '2',     '3',    '3',      '4',    '4' ],
        ['1',     '1',     '2',    '2',      '2',    '3' ],
        ['1',     '1',     '1',    '1',      '1',    '2'  ],
        ['0',     '0',     '0',    '0',      '0',    '0'  ],
      ],

      rows_color: [
        ["orange",           "orange",           "red",             "red",               "red",             "red"          ],
        ["yellow",           "yellow",           "orange",          "red",               "red",             "red"          ],
        ["limegreen",        "limegreen",        "yellow",          "yellow",            "orange",          "orange"       ],
        ["aqua",             "aqua",             "limegreen",       "limegreen",         "limegreen",       "yellow"       ],
        ["aqua",             "aqua",             "aqua",            "aqua",              "aqua",            "limegreen"    ],
        ["white",            "white",            "white",           "white",             "white",           "white"        ]
      ]
    },

    risk_definitions: {
      white:     { rating: 'None',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: '<b>Operational Impact:</b> Operation permitted<br><br><b>Minimum Action:</b> N/A<br><br><b>Immediate Notification:</b> N/A<br><br><b>Risk Acceptance and Mitigation Responsibility:</b> Management personnel in area of risk' },
      aqua:      { rating: 'Minimal (Acceptable)',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2', description: '<b>Operational Impact:</b> Operation permitted<br><br><b>Minimum Action:</b> N/A<br><br><b>Immediate Notification:</b> N/A<br><br><b>Risk Acceptance and Mitigation Responsibility:</b> Management personnel in area of risk' },
      limegreen: { rating: 'Low',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: '<b>Operational Impact:</b> Operation permitted<br><br><b>Minimum Action:</b> Monitor, consider actions to further reduce risk<br><br><b>Immediate Notification:</b> Process owner in area of risk<br><br><b>Risk Acceptance and Mitigation Responsibility:</b> Management personnel in area of risk' },
      yellow:    { rating: 'Medium',    cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',             description: '<b>Operational Impact:</b> Operation permitted<br><br><b>Minimum Action:</b> Mitigation strategy required to reduce<br><br><b>Immediate Notification:</b> VP,MD,119, Director in impacted area of risk, Mgr Safety Programs<br><br><b>Risk Acceptance and Mitigation Responsibility:</b> Director or above' },
      orange:    { rating: 'High',   cells: '3/6, 4/5, 5/4',                            description: '<b>Operational Impact:</b> Operation permitted with execution of a high priority, systemic mitigation strategy<br><br><b>Minimum Action:</b> Immediate mitigation and comprehensive mitigation to level 3 minimum required<br><br><b>Immediate Notification:</b> Positions listed for risk level 3 plus COO and President<br><br><b>Risk Acceptance and Mitigation Responsibility:</b> VP/MD in area of risk until mitigation to level 3' },
      red:       { rating: 'Extreme',      cells: '4/6, 5/5, 5/6',                            description: '<b>Operational Impact:</b> Stop the operation<br><br><b>Minimum Action:</b> Mitigation to level 4 or lower prior to operation<br><br><b>Immediate Notification:</b> Positions listed for risk level 4 plus CEO and BODSC<br><br><b>Risk Acceptance and Mitigation Responsibility:</b> VP(s) in area of risk' }
    },

    risk_table_index: {
      'None'                 => 'white',
      'Minimal (Acceptable)' => 'aqua',
      'Low'                  => 'limegreen',
      'Medium'               => 'yellow',
      'High'                 => 'orange',
      'Extreme'              => 'red',
    },

    risk_table_dict: {
      0 => 'None',
      1 => 'Minimal (Acceptable)',
      2 => 'Low',
      3 => 'Medium',
      4 => 'High',
      5 => 'Extreme',
    }
  }

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                           => 'ProSafeT',
    'Region'                         => 'Pacific',
    'ASAP MOU Holder Name'           => 'ProSafeT',
    'ASAP MOU Holder FAA Designator' => 'ProSafeT'
  })

end
