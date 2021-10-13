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
      direction: :down,
      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'SEVERITY',
      row_header: ['0&nbsp;No Safety Implication','1&nbsp;Negligible','2&nbsp;Minor','3&nbsp;Major','4&nbsp;Critical','5&nbsp;Catastrophic'],
      column_header_name: 'CATEGORY',
      column_header: ['Injury or Illness','Aircraft, Facility or Terrorism Event','Operational Compliance, Performance','Damage, Fine or Loss of Revenue','Corporate Image','Damage to the Environment'],
      rows: [
        [ # No Safety Implication
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication",
          "No Safety Implication"
        ],
        [ # Negligible
          "First Aid treatment",
          "Negligible incident or damage with extremely limited effect on safety",
          "Regulatory/Company policy and/or procedure deviation with limited safety implication",
          "Damage, fines or loss of revenue <$15K",
          "Negligible effect on Corporate image, little to no potential for negative impact on the AS/QX brand",
          "Negligible environmental effect"
        ],
        [ # Minor
          "Medical treatment beyond first aid",
          "NTSB incident or minor property damage",
          "Regulatory/Company policy and/or procedure deviation with minor safety implication",
          "Damage, fines or loss of revenue >$15K - $250K",
          "Minor effect on Corporate image, isolated effect that is easily reversible",
          "Minor environmental effect"
        ],
        [ # Moderate
          "Single overnight hospitalization",
          "NTSB incident or accident, partial loss of a facility or a credible security threat",
          "Regulatory /Company policy and/or procedure deviation with major reduction in safety margin",
          "Damage, fines or loss of revenue >$250K - $1M",
          "Major effect on Corporate image, isolated to a single location",
          "Contained effect to the environment"
        ],
        [ # Critical
          "Single fatality or multiple overnight hospital admissions",
          "NTSB accident or substantial loss of affected property",
          "Regulatory /Company policy and/or procedure deviation with a critical impact on safety",
          "Damage, fines or loss of revenue >$1M- $5M",
          "Adverse effect on Corporate image, significant impact on a region",
          "Critical environmental effect"
        ],
        [ # Catastrophic
          "Multiple fatalities",
          "Total loss of aircraft or facility",
          "Potential threat to Operating Certificate",
          "Damage, fines or loss of revenue >$5M",
          "Potential for Corporate failure, permanent impact on business system-wide",
          "Massive environmental effect"
        ]
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
      row_header: ['0&nbsp;No Safety Implication','1&nbsp;Negligible','2&nbsp;Minor','3&nbsp;Major','4&nbsp;Critical','5&nbsp;Catastrophic'],
      column_header_name: 'LIKELIHOOD',
      column_header: ['1&nbsp;Extremely Improbable','2&nbsp;Improbable','3&nbsp;Remote','4&nbsp;Occasional','5&nbsp;Frequent','6&nbsp;Repetitive'],
      rows: [
        ['0',     '0',     '0',    '0',      '0',    '0'  ],
        ['1',     '2',     '3',    '4',      '5',    '6'  ],
        ['2',     '4',     '6',    '8',      '10',   '12' ],
        ['3',     '6',     '9',    '12',     '15',   '18' ],
        ['4',     '8',     '12',   '16',     '20',   '24' ],
        ['5',     '10',    '15',   '20',     '25',   '30' ]
      ],

      rows_color: [
        ["antiquewhite",     "antiquewhite",     "antiquewhite",    "antiquewhite",      "antiquewhite",    "antiquewhite" ],
        ["aqua",             "aqua",             "aqua",            "aqua",              "aqua",            "limegreen"    ],
        ["aqua",             "aqua",             "limegreen",       "limegreen",         "limegreen",       "yellow"       ],
        ["limegreen",        "limegreen",        "yellow",          "yellow",            "orange",          "orange"       ],
        ["yellow",           "yellow",           "orange",          "red",               "red",             "red"          ],
        ["orange",           "orange",           "red",             "red",               "red",             "red"          ]
      ]
    },

    risk_definitions: {
      antiquewhite:     { rating: 'Low',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: 'Risks in this region may be accepted without further action. However, continuous analysis or trending may be appropriate to accurately monitor risk. Manager or higher acceptance is required for all risk determinations or mitigations that fall within Green region.' },
      aqua:             { rating: 'Low',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: 'Risks in this region may be accepted without further action. However, continuous analysis or trending may be appropriate to accurately monitor risk. Manager or higher acceptance is required for all risk determinations or mitigations that fall within Green region.' },
      limegreen:        { rating: 'Low',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: 'Risks in this region may be accepted without further action. However, continuous analysis or trending may be appropriate to accurately monitor risk. Manager or higher acceptance is required for all risk determinations or mitigations that fall within Green region.' },
      yellow:           { rating: 'Medium',    cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',             description: 'Actual hazards with risks falling in this region are acceptable with risk controls and monitoring. If risk controls are not possible, monitoring must be applied to ensure the risk does not elevate. Director or higher acceptance is required for risks falling within the Yellow region.' },
      orange:           { rating: 'Serious',   cells: '3/6, 4/5, 5/4',                            description: 'Actual hazards with risks falling in this region are generally unacceptable although operation is allowed to continue while a high priority, systemic mitigation strategy is carried out. An immediate interim mitigation action must be carried out prior to a compressive fix. Designated 14 CFR Part 119 personnel are responsible for mitigation strategies. If the risk cannot be mitigated to a lower risk region, managing directors and above can accept the risk. When senior management accepts a risk in the orange region, 14 CFR Part 119 personnel must monitor to ensure risk does not elevate.' },
      red:              { rating: 'High',      cells: '4/6, 5/5, 5/6',                            description: 'Actual hazards with risks falling in this region require immediate action to eliminate the hazard or control the factors leading to its higher likelihood or severity. Operation must not begin or continue without mitigation to as low as reasonably practicable (ALARP) risk level, provided it is in a lower risk region. Designated 14 CFR Part 119 personnel are responsible for mitigation strategies; however, the Accountable Executive must review and approve mitigations from the Red region to a lower risk region.' }
    },

    risk_table_index: {
      'Low - 0' => 'limegreen',
      'Low - 1' => 'limegreen',
      'Low - 2' => 'limegreen',
      'Low - 3' => 'limegreen',
      'Low - 4' => 'limegreen',
      'Low - 5' => 'limegreen',
      'Low - 6' => 'limegreen',
      'Low - 8' => 'limegreen',
      'Low' =>  'limegreen',
      'LOW' =>  'limegreen',
      'Medium - 9' => 'yellow',
      'Medium - 10' => 'yellow',
      'Medium - 12' => 'yellow',
      'Medium' => 'yellow',
      'MEDIUM' => 'yellow',
      'Serious - 15' => 'orange',
      'Serious - 16' => 'orange',
      'Serious - 18' => 'orange',
      'Serious - 20' => 'orange',
      'Serious' => 'orange',
      'SERIOUS' => 'orange',
      'High - 24' => 'red',
      'High - 25' => 'red',
      'High - 30' => 'red',
      'High' => 'red',
      'HIGH' => 'red',
    },

    risk_table_dict: {
      0 => 'Low - 0',
      1 => 'Low - 1',
      2 => 'Low - 2',
      3 => 'Low - 3',
      4 => 'Low - 4',
      5 => 'Low - 5',
      6 => 'Low - 6',
      8 => 'Low - 8',
      9 => 'Medium - 9',
      10 => 'Medium - 10',
      12 => 'Medium - 12',
      15 => 'Serious - 15',
      16 => 'Serious - 16',
      18 => 'Serious - 18',
      20 => 'Serious - 20',
      24 => 'High - 24',
      25 => 'High - 25',
      30 => 'High - 30',
    }
  }

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                           => 'ProSafeT',
    'Region'                         => 'Pacific',
    'ASAP MOU Holder Name'           => 'ProSafeT',
    'ASAP MOU Holder FAA Designator' => 'ProSafeT'
  })

end
