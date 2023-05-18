class RZNConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Gridiron Air LLC',
    time_zone:                    'Mountain Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:                             true,
    enable_sso:                                 false,

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
      row_header: ['Catastrophic','Critical','Major','Minor','Negligible','No Safety Impact'],
      column_header_name: 'CATEGORY',
      column_header: ['Injury/Illness',"Aircraft, Facility, Terrorism Event",'Operational Compliance Performance','Damage, Fine, Loss of Revenue','Corporate Image, Brand Image','Environment Impact'],
      rows: [
        [ # Catastrophic
          "Multiple Fatalities",
          "Total loss of Aircraft or Facility",
          "Potential threat to Operating Certificate",
          "Damage, Fines, Loss of Revenue > $5M",
          "Potential for Corporate failure, permanent impact on business system-wide",
          "Massive environmental effect"
        ],
        [ # Critical
          "Single Fatality or Multiple overnight hospital admissions",
          "NTSB reportable accident or substantial loss of affected property",
          "Regulatory/Company Policy and/or Procedure deviation with a critical impact on Safety",
          "Damage, Fines, Loss of Revenue $1-5M",
          "Adverse effect on Corporate Image, Significant impact on a region",
          "Large environmental effect"
        ],
        [ # Major
          "Single overnight hospitalization",
          "NTSB reportable incident or accident, partial loss of a facility or a credible security threat",
          "Regulatory/Company Policy and/or Procedure deviation with major impact on Safety",
          "Damage, Fines, Loss of Revenue $250K-1M",
          "Major effect on Corporate Image, isolated to a single location",
          "Contained environmental effect"
        ],
        [ # Minor
          "Medical treatment beyond first aid",
          "NTSB reportable incident or minor property damage",
          "Procedure deviation with minor impact on Safety",
          "Damage, Fines, Loss of Revenue $15K-250K",
          "Minor effect on Corporate Image or brand, isolated effect that is easily manageable",
          "Minor environmental effect"
        ],
        [ # Negligible
          "First aid treatment",
          "Negligible incident or damage with negligible effect on Safety",
          "Procedure deviation with negligible Safety implication",
          "Damage, Fines, Loss of Revenue </= $15K",
          "Negligible effect on Corporate Image or brand, little to no potential negative impact",
          "Negligible environmental effect"
        ],
        [ # No Impact
          "No Safety Impact",
          "No Safety Impact",
          "No Safety Impact",
          "No Safety Impact",
          "No Safety Impact",
          "No Safety Impact"
        ]
      ]
    },

    severity_table_dict: {
      0 => 'Catastrophic',
      1 => 'Critical',
      2 => 'Major',
      3 => 'Minor',
      4 => 'Negligible',
      5 => 'No Safety Impact'
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
      column_header: ['Extremely Improbable','Improbable','Remote','Occasional','Frequent'],
      rows: [
        [
          "<b>Once in 10 yrs +</b>",
          "<b>Once in 2-10 yrs</b>",
          "<b>Once in < 2 yrs</b>",
          "<b>Times per year (2-11)</b>",
          "<b>Times per year (> 12)</b>",
        ]
      ]
    },

    probability_table_dict: {
      0 => 'Extremely Improbable',
      1 => 'Improbable',
      2 => 'Remote',
      3 => 'Occasional',
      4 => 'Frequent'
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
      row_header: ['Catastrophic','Critical','Major','Minor','Negligible','No Safety Impact'],
      column_header_name: 'LIKELIHOOD',
      column_header: ['Extremely Improbable','Improbable','Remote','Occasional','Frequent'],
      rows: [
        ['2',     '3',     '4',    '5',      '5' ],
        ['2',     '3',     '4',    '5',      '5' ],
        ['2',     '2',     '3',    '3',      '4' ],
        ['1',     '1',     '2',    '2',      '2' ],
        ['1',     '1',     '1',    '1',      '1' ],
        ['0',     '0',     '0',    '0',      '0' ]
      ],

      rows_color: [
        ["limegreen",     "yellow",        "orange",       "red",            "red"          ],
        ["limegreen",     "yellow",        "orange",       "red",            "red"          ],
        ["limegreen",     "limegreen",     "yellow",       "yellow",         "orange"       ],
        ["lightskyblue",  "lightskyblue",  "limegreen",    "limegreen",      "limegreen"    ],
        ["lightskyblue",  "lightskyblue",  "lightskyblue", "lightskyblue",   "lightskyblue" ],
        ["white",         "white",         "white",        "white",          "white"        ]
      ]
    },

    risk_definitions: {
      red:              { rating: 'Extreme - 5',   cells: '4/6, 5/5, 5/6',                            description: '<ul><li><b>Operational Impact: </b>Stop the Operation</li><li><b>Minimum Action Plan: </b>Mitigation to Level 4 or lower prior to operation</li><li><b>Immediate Notification Area: </b>14 CFR Part 119.65 post holder in impacted area and the Director of Safety</li><li><b>Risk Acceptance/Responsibility: </b>Accountable Executive</li></ul>' },
      orange:           { rating: 'High - 4',      cells: '3/6, 4/5, 5/4',                            description: '<ul><li><b>Operational Impact: </b>Operation permitted with execution of a high priority, systematic mitigation plan</li><li><b>Minimum Action Plan: </b>Immediate and thorough mitigation reducing risk to Level 3</li><li><b>Immediate Notification Area: </b>14 CFR Part 119.65 post holder in impacted area and the Director of Safety</li><li><b>Risk Acceptance/Responsibility: </b>Chief Operating Officer(COO) or Chief Technical Officer(CTO)</li></ul>' },
      yellow:           { rating: 'Medium - 3',    cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',             description: '<ul><li><b>Operational Impact: </b>Operation Permitted</li><li><b>Minimum Action Plan: </b>Mitigation mandatory to reduce risk(s)</li><li><b>Immediate Notification Area: </b>Director(s) in impacted area and the Director of Safety</li><li><b>Risk Acceptance/Responsibility: </b>14 CFR Part 119.65 Director in area of Risk</li></ul>' },
      limegreen:        { rating: 'Low - 2',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: '<ul><li><b>Operational Impact: </b>Operation Permitted</li><li><b>Minimum Action Plan: </b>Monitor processes and procedures</li><li><b>Immediate Notification Area: </b>Person with Authority in impacted area and Director of Safety</li><li><b>Risk Acceptance/Responsibility: </b>Manager in area of Risk</li></ul>' },
      lightskyblue:     { rating: 'Minimal - 1',   cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: '<ul><li><b>Operational Impact: </b>Operation Permitted</li><li><b>Minimum Action Plan: </b>N/A</li><li><b>Immediate Notification Area: </b>N/A</li><li><b>Risk Acceptance/Responsibility: </b>Manager in area of Risk</li></ul>' },
      white:            { rating: 'None - 0',      cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: '<ul><li><b>Operational Impact: </b>Operation Permitted</li><li><b>Minimum Action Plan: </b>N/A</li><li><b>Immediate Notification Area: </b>N/A</li><li><b>Risk Acceptance/Responsibility: </b>N/A</li></ul>' },
    },

    risk_definitions_additional_info: "RISK: FAILURE TO MAINTAIN SAFE, COMPLIANT AND RELIABLE OPERATIONS<br/>All Risk Mitigation plans must be approved by the teammember that holds the authority for the risk(s) within 30 days for Level > 3.",

    risk_table_index: {
      'None'        =>  'white',
      'None - 0'    =>  'white',
      'NONE'        =>  'white',
      'Minimal'     =>  'lightskyblue',
      'Minimal - 1' =>  'lightskyblue',
      'MINIMAL'     =>  'lightskyblue',
      'Low'         =>  'limegreen',
      'Low - 2'     =>  'limegreen',
      'LOW'         =>  'limegreen',
      'Medium'      => 'yellow',
      'Medium - 3'  => 'yellow',
      'MEDIUM'      => 'yellow',
      'High'        => 'orange',
      'High - 4'    => 'orange',
      'HIGH'        => 'orange',
      'Extreme'     => 'red',
      'Extreme - 5' => 'red',
      'EXTREME'     => 'red'
    },

    risk_table_dict: {
      white:        'None',
      lightskyblue: 'Minimal',
      limegreen:    'Low',
      yellow:       'Medium',
      orange:       'High',
      red:          'Extreme'
    }
  }

end
