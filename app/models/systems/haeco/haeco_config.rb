class HAECOConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'HAECO Americas',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:                true,
    global_admin_default:          false,
    enable_sso:                    true,
    login_option:                  'dual',
    has_mobile_app:                true,
    sms_im_visibility:             false,
    checklist_query:               true,

    hide_employee_group:           true,
    custom_uniq_id:                true,
    hide_findings_in_checklist:    true
  })

  DOCUMENT_CATEGORIES = ["HAECO References Information", "ProSafeT Information", "General Information", "Safety Reporting Guides Information", "Safety Assurance Guides Information", "SRA(SRM) Guides Information", "SMS IM Guides Information", "Other"]


  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Baseline Risk',
      mitigate_btn: 'Mitigate Risk',
      'Baseline' => 'Baseline',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY EXERCISE',

      orientation: :horizontal,
      direction: :right,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: '',
      row_header: [
        '',
        '',
        ''
      ],
      column_header_name: 'SEVERITY',
      column_header: ['Negligible', 'Minor', 'Moderate', 'Major', 'Catastrophic'],
      rows: [
        ["Little consequences.", "Minor damage.", "Extensive damage (non-structural).", "Significant  Structural damage.", "Fatality."],
        ["No significance  to aircraft-related operational  safety.", "Degrades or affects normal aircraft operational procedures or performance.", "Partial loss of significant/ major aircraft systems or results in abnormal flight operations procedure application.", "Complete failure of significant/ major aircraft systems or results in application of emergency flight procedures.", "Loss of aircraft."],
        ["First aid injury. Discrepancies found on a safety audit which have low potential of leading to an injury.", "Recordable injury. Identified hazard which seems isolated in nature. Minor reported hazards which could result in an injury if left uncorrected.", "Lost Time Injury. Safety trending that indicates a failure within the safety process.", "1> hospitalized from complete failure of a safety critical component.<br><br>Hospitalization requiring urgent operation or permanent total incapacity.<br><br>Large scale event which could lead to 3> employees  obtaining  adverse health effects.", "Complete failure of a safety critical component resulting in the death of an Individual(s)."]
      ]
    },

    severity_table_dict: {
      0 => 'Negligible',
      1 => 'Minor',
      2 => 'Moderate',
      3 => 'Major',
      4 => 'Catastrophic',
    },

    probability_table: {
      title: 'PROBABILITY EXERCISE',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: 'PROBABILITY',
      row_header: ['Frequent', 'Occasional', 'Remote', 'Improbable', 'Extremely Improbable'],
      column_header_name: '',
      column_header: ['CLASS'],
      rows: [
        ["<b>Likely to occur many times</b><br>
         (has occurred frequently, one or more times per month)"],
        ["<b>Likely to occur sometimes</b><br>
         (has occurred infrequently,  once per year or less)"],
        ["<b>Unlikely but possible to occur</b><br>
         (has occurred rarely, once every 3-5 years or less)"],
        ["<b>Very unlikely to occur</b><br>
         (not known to have occurred)"],
        ["<b>Almost inconceivable that the event will occur</b>"],
      ]
    },

    probability_table_dict: {
      0 => 'Frequent',
      1 => 'Occasional',
      2 => 'Remote',
      3 => 'Improbable',
      4 => 'Extremely Improbable',
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

      row_header_name: 'PROBABILITY',
      row_header: ['Frequent', 'Occasional', 'Remote', 'Improbable', 'Extremely Improbable'],
      column_header_name: 'SEVERITY',
      column_header: ['Negligible', 'Minor', 'Moderate', 'Major', 'Catastrophic'],
      rows: [
        ['5x1',   '5x2',    '5x3',    '5x4',    '5x5'  ],
        ['4x1',   '4x2',    '4x3',    '4x4',    '4x5' ],
        ['3x1',   '3x2',    '3x3',    '3x4',    '3x5' ],
        ['2x1',   '2x2',    '2x3',    '2x4',    '2x5' ],
        ['1x1',   '1x2',    '1x3',    '1x4',    '1x5' ]
      ],
      rows_color: [
        ['yellow',       'orange',       'red',         'red',        'red'],
        ['yellow',       'yellow',       'orange',      'red',        'red'],
        ['limegreen',    'yellow',       'yellow',      'orange ',    'red'],
        ['limegreen',    'limegreen',    'yellow',      'yellow',     'orange'],
        ['limegreen',    'limegreen',    'limegreen',   'yellow',     'yellow']
      ],
    },

    risk_definitions: {
      limegreen: {rating: "ACCEPTABLE", description: "Acceptable as is. No further risk mitigation required." },
      yellow:    {rating: "LOW",        description: "For statistics only or minimal intervention (ALARP)" },
      orange:    {rating: "MODERATE",   description: "Requires Risk mitigation Action with specific owner identified, and implementation time determined.<br>Normally managed by routine procedures, procedure reviews, or minor mitigation." },
      red:       {rating: "HIGH",       description: "Specific Risk Mitigation Action Plan required before operation re-starts." },
    },

    risk_table_index: {
      'ACCEPTABLE' => 'limegreen',
      'LOW'        => 'yellow',
      'MODERATE'   => 'orange',
      'HIGH'       => 'red',
    },

    risk_table_dict: {
      limegreen:  'ACCEPTABLE',
      yellow:     'LOW',
      orange:     'MODERATE',
      red:        'HIGH',
    }
  }
end
