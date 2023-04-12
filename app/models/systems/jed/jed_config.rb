class JEDConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'King Abdulaziz International Airport',
    time_zone:                    'Riyadh',

    # SYSTEM CONFIGS
    has_mobile_app:               false,
  })

  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Baseline Risk',
      mitigate_btn: 'Mitigate Risk',
      'Baseline' => 'Baseline',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY OF OCCURRENCE',

      orientation: :horizontal,
      direction: :left,
      size: 'col-xs-8',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      column_header_name: 'VALUE',
      column_header: ['A','B','C','D','E'],
      row_header_name: '',
      row_header: [
        'Outcome Definition'
      ],
      rows: [
        [ #A
          '<b>Catastrophic</b></br>Equipment Destroyed</br>Multiple deaths',
          #B
          '<b>Hazardous</b></br>A large reduction in safety margins, physical distress or a workload such that operators cannot be relied upon to perform their tasks accurately or completely</br>Serious injury or deat to a number of people</br>Major equipment damage',
          #C
          '<b>Major</b></br>A significant reduction in safety margins, a reduction in the ability of the operators to coope with adverse operating conditions as a result of conditions impairing their efficiency.</br>Serious incident</br>Injury to persons',
          #D
          '<b>Minor</b></br>Nuisance.</br>Operating limitations.</br>Using of emergency procedures.</br>Minor incident',
          #E
          '<b>Negligible</b></br>Almost inconceivable that the event will occur'
        ]
      ]
    },

    severity_table_dict: {
      0 => '1',
      1 => '2',
      2 => '3',
      3 => '4',
      4 => '5'
    },

    probability_table: {
      title: 'PROBABILITY OF OCCURENCE',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-4',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: 'VALUE',
      row_header: ['5', '4', '3', '2', '1'],
      column_header_name: 'QUALITATIVE DEFINITION',
      column_header: [''],
      rows: [
        [ #5
          "<center><b>Frequent</b></center>Likely to occur many times (Has occured frequently)"
        ],
        [ #4
          "<center><b>Occasional</b></center>Likely to occur sometimes (Has occured infrequently)"
        ],
        [ #3
          "<center><b>Remote</b></center>Unlikely, but possible to occur (Has occured rarely)"
        ],
        [ #2
          "<center><b>Improbable</b></center>Very unlikely to occur (Not known has occured)"
        ],
        [ #1
          "<center><b>Extremely Improbable</b></center>Almost inconceivable that the event will occur"
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D',
      4 => 'E'
    },

    risk_table: {
      title: 'SAFETY RISK ASSESSMENT MATRIX',

      size: 'col-xs-8',
      title_style: 'matrixTitle',
      main_header_style: 'matrixMainHeader',
      header_style: 'matrixHeader',
      cell_name: 'risk_td',
      cell_style: 'bold',

      # maps severity / likelihood attribute to position on table
      severity_pos: 'column',
      likelihood_pos: 'row',

      column_header_name: 'SEVERITY',
      column_header: ['Catastrophic A','Hazardous B','Major C','Minor D','Negligible E'],
      row_header_name: 'PROBABILITY',
      row_header: ['5 Frequent', '4 Occasional', '3 Remote', '2 Improbable', '1 Extremely Improbable'],
      rows: [
        ['5A',     '5B',     '5C',    '5D',      '5E'],
        ['4A',     '4B',     '4C',    '4D',      '4E'],
        ['3A',     '3B',     '3C',    '3D',      '3E'],
        ['2A',     '2B',     '2C',    '2D',      '2E'],
        ['1A',     '1B',     '1C',    '1D',      '1E']
      ],

      rows_color: [
        ["crimson",     "crimson",      "crimson",          "yellow",         "yellow"     ],
        ["crimson",     "crimson",      "yellow",           "yellow",         "yellow"     ],
        ["crimson",     "yellow",       "yellow",           "yellow",    "mediumseagreen"  ],
        ["yellow",      "yellow",       "yellow",      "mediumseagreen", "mediumseagreen"  ],
        ["yellow","mediumseagreen", "mediumseagreen",  "mediumseagreen", "mediumseagreen"  ]
      ],
    },

    risk_table_index: {
      "High" => 'crimson',
      "Serious" => 'coral',
      "Moderate" => 'yellow',
      "Minor" => 'steelblue',
      "Low" => 'mediumseagreen'
    },

    risk_table_dict: {
      crimson:        "High",
      coral:          "Serious",
      yellow:         "Moderate",
      steelblue:      "Minor",
      mediumseagreen: "Low",
    },

    risk_definitions: {
      crimson:          { rating: 'High Risk', cells: '', description: 'Unacceptable under the existing circumstances' },
      yellow:           { rating: 'Moderate Risk',   cells: '', description: 'Acceptable based on risk mitigation. It may require management decision.' },
      mediumseagreen:           { rating: 'Low Risk',  cells: '', description: 'Acceptable' }
    },
  }

end
