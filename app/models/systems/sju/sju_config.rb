class SJUConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Luis Muñoz Marín International Airport',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS    
    advanced_checklist_data_type:  true,
    checklist_query:               true,

    has_gmap:                      true,
    gis_layers:                    true,
    lat:                           18.438055,
    lng:                           -66.004444,
    gMapZoom:                      15,

    global_admin_default:          false,
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
      direction: :right,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'CLASS',
      row_header: [
        'Safety (Impact)',
        'People (Injury)',
        'Security (Threat)',
        'Environment (Effect)',
        'Assets (Damage)'
      ],
      column_header_name: 'SEVERITY',
      column_header: ['VL', 'L', 'M', 'H', 'VH'],
      rows: [
        [ 'Negligible', 'Slight',  'Minor',    'Major',   'Massive'            ],
        [ 'Negligible', 'Slight',  'Minor',    'Major',   'Fatality/Disability'],
        [ 'Negligible', 'Low',     'Medium',   'High',    'Extreme'            ],
        [ 'Negligible', 'Minor',   'Moderate', 'Major',   'Catastrophic'       ],
        [ 'Negligible', 'Slight',  'Minor',    'Major',   'Massive'            ]
      ]
    },

    severity_table_dict: {
      0 => 'VL',
      1 => 'L',
      2 => 'M',
      3 => 'H',
      4 => 'VH',
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
      row_header: ['VH', 'H', 'M', 'L', 'VL'],
      column_header_name: '',
      column_header: ['Description'],
      rows: [
        ['Frequent (30 Days)'],
        ['Probable (6 Months)'],
        ['Occasional (1 Year)'],
        ['Remote (5 Years)'],
        ['Improbable (10 Years)'],
      ]
    },

    probability_table_dict: {
      0 => 'VH',
      1 => 'H',
      2 => 'M',
      3 => 'L',
      4 => 'VL',
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
      row_header: ['VH', 'H', 'M', 'L', 'VL'],
      column_header_name: 'SEVERITY',
      column_header: ['VL', 'L', 'M', 'H', 'VH'],

      rows_color: [
        ['limegreen', 'yellow',    'red',       'red',    'red'],
        ['limegreen', 'yellow',    'red',       'red',    'red'],
        ['limegreen', 'limegreen', 'yellow',    'red',    'red'],
        ['limegreen', 'limegreen', 'yellow',    'red', 'red'],
        ['limegreen', 'limegreen', 'limegreen', 'yellow', 'red']
      ],
    },

    risk_definitions: {
      limegreen: {rating: "LOW",      cells: "A1, B2, C3, D4", description: "Acceptable"                   },
      yellow:    {rating: "MODERATE", cells: "A2, B2, C4",     description: "Acceptable with Mitigation"   },
      red:       {rating: "HIGH",     cells: "A4, A3, B4",     description: "Unacceptable"                 },
    },

    risk_table_index: {
      'MODERATE' => 'yellow',
      'LOW'      => 'limegreen',
      'HIGH'     => 'red',
    },

    risk_table_dict: {
      limegreen:  'LOW',
      yellow:     'MODERATE',
      red:        'HIGH',
    }
  }
end
