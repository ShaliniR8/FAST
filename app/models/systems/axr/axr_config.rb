class AXRConfig < DefaultConfig

  # Used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  # Used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = ['ASAP', 'SMS']

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Archer Aviation',
    time_zone:                    'Pacific Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:               true,
    login_option:                 'dual',


    # TO BE REMOVED:
    sms_im_visibility:            false,
    safety_promotion_visibility:  true
  })

  RISK_MATRIX = {
    :likelihood       => ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
    :severity         => (0..4).to_a.reverse,
    :risk_factor      => {"0" => "white", "1" => "skyblue", "2" => "limegreen", "3" => "yellow", "4" => "orange", "5" => "red"},
  }


  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Baseline Risk',
      mitigate_btn: 'Mitigate Risk',
      'Baseline' => 'Baseline',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY EXERCISE',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-8',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: '',
      row_header: ['CATASTROPHIC','CRITICAL','MAJOR','MINOR','NEGLIGIBLE', 'NO SAFETY </br> IMPACT'],
      column_header_name: 'SEVERITY',
      column_header: [
        'Injury / Illness',
        'Aircraft, Facility, Terrorism Event',
        'Operational Compliance Performance',
        'Damage, Fine, Loss of Revenue',
        'Corporate image, Brand Damage',
        'Environment Impact'],
      rows: [
        [ 'Multiple Fatalities',    'Total loss of Aircraft or Facility',  'Potential threat to Operating Certificate',     'Damage, Fines, Loss of Revenue >$5M',   'Potential for Corporate failure, permanent impact on business system-wide', "Massive environmental effect"      ],
        [ 'Single Fatality or Multiple overnight hospital admissions',     'NTSB reportable accident or substantial loss of affected property', 'Regulatory/Company Policy and/or Procedure deviation with critical impact on Safety',  'Damage, Fines, Loss of Revenue $1-5M',  'Adverse effect on Corporate image, Significant impact on a region', 'Large environmental effect'        ],
        [ 'Single overnight Hospitalization',  'NTSB reportable incident or accident, partial loss of a facility or a credible security threat', 'Regulatory/Company Policy and/or Procedure deviation with major impact on Safety',      'Damage, Fines, Loss of Revenue $250K-1M',  'Major effect on Corporate image, isolated to a single location', 'Contained environmental effect'        ],
        [ 'Medical treatment beyond first aid',     'NTSB reportable incident or minor property damage', 'Procedure deviation with minor impact on Safety', 'Damage, Fines, Loss of Revenue $15K-250K', 'Minor effect on Corporate image or branch, isolated effect that is easily manageable', 'Minor environmental effect' ],
        [ 'First aid treatment', 'Negligible incident or damage with negligible effect on safety',  'Procedure deviation with negligible Safety implication', 'Damage, fines, Loss of revenue </=$15K', 'Negligible effect on Corporate image or brand, little to no potential negative impact', 'Negligible environmental impact'   ],
        [ 'No Safety Impact', 'No Safety Impact', 'No Safety Impact', 'No Safety Impact', 'No Safety Impact', 'No Safety Impact']
      ]
    },

    severity_table_dict: {
      0 => "5",
      1 => "4",
      2 => "3",
      3 => "2",
      4 => "1",
      5 => "0",
    },

    probability_table: {
      title: 'PROBABILITY EXERCISE',

      orientation: :horizontal,
      direction: :right,
      size: 'col-xs-4',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: '',
      row_header: [''],
      column_header_name: 'PROBABILITY',
      column_header: ['Extremely Improbable','Improbable','Remote','Occasional','Frequent'],
      rows: [
        [
          'Once in 10 yrs +',
          'Once in 2-10 yrs',
          'Once in < 2 yrs',
          'Times per year (2-11)',
          'Times per year (>12)'
        ]
      ]
    },

    probability_table_dict: {
      0 => 'A - Improbable',
      1 => 'B - Unlikely',
      2 => 'C - Remote',
      3 => 'D - Probable',
      4 => 'E - Frequent',
    },

    risk_table: {
      title: 'ARCHER SAFETY RISK ASSESSMENT MATRIX',

      size: 'col-xs-4',
      title_style: 'matrixTitle',
      main_header_style: 'matrixMainHeader',
      header_style: 'matrixHeader',
      cell_name: 'risk_td',
      cell_style: 'bold',

      # maps severity / likelihood attribute to position on table
      severity_pos: 'row',
      likelihood_pos: 'column',

      row_header_name: '',
      row_header: ['CATASTROPHIC','CRITICAL','MAJOR','MINOR','NEGLIGIBLE', 'NO SAFETY </br> IMPACT'],
      column_header_name: 'LIKELIHOOD',
      column_header: ['Extremely Improbable','Improbable','Remote','Occasional','Frequent'],

      rows_color: [
        ['limegreen',      'yellow',       'orange',       'red',             'red' ],
        ['limegreen',      'yellow',       'orange',       'red',             'red' ],
        ['limegreen',      'limegreen',    'yellow',       'yellow',       'orange' ],
        ['skyblue',        'skyblue',      'limegreen',    'limegreen',  'limegreen'],
        ['skyblue',        'skyblue',      'skyblue',      'skyblue',      'skyblue'],
        ['white',          'white',        'white',        'white',          'white']
      ],

      rows: [
        ['2',      '3',       '4',       '5',          '5' ],
        ['2',      '3',       '4',       '5',          '5' ],
        ['2',      '2',       '3',       '3',          '4' ],
        ['1',      '1',       '2',       '2',          '2' ],
        ['1',      '1',       '1',       '1',          '1' ],
        ['0',      '0',       '0',       '0',          '0' ],
      ]
    },

    risk_definitions: {
      red:         { rating: 'Extreme (Unacceptable)',              description: "<b>Operational Impact:</b></br>Stop the operation</br></br><b>Minimum Action Plan:</b></br>Mitigation to Level 4 or lower prior to operation</br></br><b>Immediate Notification Area:</b></br>VP(s) in impacted area & SMS Manager</br></br><b>Risk Acceptance/Responsibility:</b></br>Accountable Executive"},
      orange:      { rating: 'High (Unacceptable)',                 description: "<b>Operational Impact:</b></br>Operation permitted with execution of a high priority, systematic mitigation plan</br></br><b>Minimum Action Plan:</b></br>Immediate and thorough mitigation reducing risk to</br>Level 3</br></br><b>Immediate Notification Area:</b></br>VP(s) in impacted area & SMS Manager</br></br><b>Risk Acceptance/Responsibility:</b></br>VP in area of Risk"},
      yellow:      { rating: 'Medium (Acceptable with mitigation)', description: "<b>Operational Impact:</b></br>Operation permitted</br></br><b>Minimum Action Plan:</b></br>Mitigation mandatory to reduce risk(s)</br></br><b>Immediate Notification Area:</b></br>Director(s) in impacted area & SMS Manager</br></br><b>Risk Acceptance/Responsibility:</b></br>Director in area of Risk"},
      limegreen:   { rating: 'Low (Acceptable)',                    description: "<b>Operational Impact:</b></br>Operation permitted</br></br><b>Minimum Action Plan:</b></br>Monitor processes and procedures</br></br><b>Immediate Notification Area:</b></br>Person with Authority in impacted area & SMS Manager</br></br><b>Risk Acceptance/Responsibility:</b></br>Manager in area of Risk"},
      skyblue:     { rating: 'Minimal (Acceptable)',                description: "<b>Operational Impact:</b></br>Operation permitted</br></br><b>Minimum Action Plan:</b></br>N/A</br></br><b>Immediate Notification Area:</b></br>N/A</br></br><b>Risk Acceptance/Responsibility:</b></br>Manager in area of Risk"},
      white:       { rating: 'None',                                description: "<b>Operational Impact:</b></br>Operation permitted</br></br><b>Minimum Action Plan:</b></br>N/A</br></br><b>Immediate Notification Area:</b></br>N/A</br></br><b>Risk Acceptance/Responsibility:</b></br>N/A"},
    },

    risk_table_index: {
      'Orange - Unacceptable'                => 'orange',
      'Yellow - Acceptable with mitigation'  => 'yellow',
      'Green - Acceptable'                   => 'limegreen',
      'Red - Unacceptable'                   => 'red',

      'Orange'   => 'orange',
      'Yellow'   => 'yellow',
      'Green'    => 'limegreen',

      'Moderate' => 'yellow',
      'Low'      => 'limegreen',
      'High'     => 'red',

      'MODERATE' => 'yellow',
      'LOW'      => 'limegreen',
      'HIGH'     => 'red',
    },

    risk_table_dict: {
      limegreen:  'Green - Acceptable',
      red:        'Red - Unacceptable',
      yellow:        'Yellow - Acceptable with mitigation',
      orange:        'Orange - Unacceptable',

    }
  }
end
