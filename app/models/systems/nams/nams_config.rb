class NAMSConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  MOBILE_MODULES = %w[ASAP]


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Northern Air Cargo',
    time_zone:                          'Alaska',

    # SYSTEM CONFIGS
    has_mobile_app:                     true,

    # SYSTEM-WIDE FORM CONFIGS
    allow_reopen_report:                false,
    base_risk_matrix:                   false,

  })


  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    "CHDO"=>"FAA Flight Standards District Office, 300W 36th Ave, Suite 101, Anchorage, AK, 99503",
    "Region"=>"Anchorage",
    "ASAP MOU Holder Name"=>"N/A",
    "ASAP MOU Holder FAA Designator"=>"N/A"
  })


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
      direction: :left,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',
      column_header_name: 'SEVERITY',
      column_header: ['I','II','III','IV'],
      row_header_name: 'CLASS',
      row_header: [
        'Accident or Incident',
        'Employee or Customer Injury',
        'Aircraft Operational Events',
        'Airworthiness',
        'Documented Systems, Policies, and Processes',
        'Audit Finding',
        'Security',
        'HSE / Other Regulatory or General Issue',
      ],

      rows: [
        [
          'Accident with serious injuries or fatality; aircraft hull loss; loss of property',
          'Accident or incident with serious injury; substantial damage to aircraft or property',
          'Incident with minor injuries; minor damage to aircraft or property',
          'Incident with no injuries; cosmetic damage to aircraft or property',
        ],
        [
          'Fatality or serious injury resulting in permanent disability / loss of capacity',
          'Emergency care required; hospitalization; temporary disability / loss of capacity',
          'Non-emergency medical care required',
          'Minor injury; no medical treatment required'
        ],
        [
          'Impacts the immediate safe operation of an aircraft',
          'Impacts the continued safe operation of an aircraft',
          'May impact the safe operation of an aircraft',
          'May impact normal operation of an aircraft',
        ],
        [
          'Aircraft returned to service and operated in an un-airworthy, or unsafe condition',
          'Aircraft returned to service and operated in an un-airworthy, but not unsafe condition',
          'Aircraft returned to service in an un-airworthy and unsafe condition, but not operated',
          'Aircraft returned to service in an un-airworthy condition, but not considered unsafe and not operated',
        ],
        [
          'Loss or breakdown of entire system',
          'Loss or breakdown of process; non-compliance with regulatory policies',
          'Deficiencies leading to poor dependability or disruption of processes; non-conformance with organizational policies',
          'Procedural inconsistencies resulting in conflicting or unclear instructions',
        ],
        [
          'Immediate Safety Concern / Violation',
          'Regulatory Non-Compliance',
          'Non-Conformance with organizational policies / procedures',
          'Concern',
        ],
        [
          'Willful',
          'Repeat',
          'Serious',
          'Inadvertent',
        ],
        [
          'Willful and/or major regulatory violation',
          'Repeat and/or moderate regulatory deviation',
          'Serious and/or organizational policy / procedure non-compliance',
          'General / Other',
        ]
      ]
    },

    severity_table_dict: {
      0 => "I",
      1 => "II",
      2 => "III",
      3 => "IV",
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
      column_header_name: 'CRITERIA',
      row_header: ['A', 'B', 'C', 'D'],
      column_header: ['Audit Findings', 'Events'],

      rows: [
        [
          'Multiple findings on current and previous audit',
          'Occurs or expacted to occur repeatedly until action is taken to mitigate the cause; follows a known trend or pattern',
        ],
        [
          'Multiple findings on current audit',
          'Occurs or may occur regularly (within the last year) if no action is taken to mitigate the cause; may repeat; identified by trends or pattern',
        ],
        [
          'Single finding on current audit and previous audit',
          'Occurs or may occur infrequently (within the last 5 years); unlikely to repeat; difficult to predict by current treads or patterns',
        ],
        [
          'Single finding on current audit / Concern',
          'One-time isolated event; not expected to repeat; not detectable by current trends or patterns',
        ],
      ]
    },

    probability_table_dict: {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D',
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
      row_header: ['4', '3', '2', '1', '0'],
      column_header_name: 'SEVERITY',
      column_header: ['I','II','III','IV'],
      row_header: ['A', 'B', 'C', 'D'],
      rows_color: [
        ['crimson',     'crimson',          'coral',              'yellow'              ],
        ['crimson',     'coral',            'yellow',             'mediumseagreen'    ],
        ['coral',       'yellow',           'yellow',             'mediumseagreen'    ],
        ['yellow',      'mediumseagreen',   'mediumseagreen',     'mediumseagreen'    ],
      ]
    },

    risk_definitions: {
      crimson:          {rating: "HIGH",      cells: "A/I, A/II, and B/I",                    description: ""},
      coral:            {rating: "SERIOUS",   cells: "A/III, B/II, and C/I",                  description: ""},
      yellow:           {rating: "MODERATE",  cells: "A/IV, B/III, C/II, C/III, and D/I",     description: ""},
      mediumseagreen:   {rating: "LOW",       cells: "B/IV, C/IV, D/II, D/III and D/IV",      description: ""}
    },

    risk_table_index: {
      "HIGH" => 'crimson',
      "SERIOUS" => 'coral',
      "MODERATE" => 'yellow',
      "LOW" => 'mediumseagreen'
    },

    risk_table_dict: {
      crimson:        "HIGH",
      coral:          "SERIOUS",
      yellow:         "MODERATE",
      mediumseagreen: "LOW"
    },


  }

end
