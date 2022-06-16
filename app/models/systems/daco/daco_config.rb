class DACOConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'King Fahd International Airport',
    time_zone:                    'Riyadh',

    # SYSTEM CONFIGS    
    advanced_checklist_data_type:  true,
    checklist_query:               true,

    has_gmap:                      true,
    gis_layers:                    true,

    lat:                           26.468719,
    lng:                           49.800733,
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
      direction: :left,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: ' ',
      row_header: [
        'CLASS'
      ],
      column_header_name: 'SEVERITY',
      column_header: ['Catastrophic', 'Hazardous', 'Major', 'Minor', 'Negligible'],
      rows: [
        [ 'A', 'B', 'C', 'D', 'E'],
      ]
    },

    severity_table_dict: {
      0 => 'Catastrophic A',
      1 => 'Hazardous B',
      2 => 'Major C',
      3 => 'Minor D',
      4 => 'Negligible E',
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
        ['5'],
        ['4'],
        ['3'],
        ['2'],
        ['1'],
      ]
    },

    probability_table_dict: {
      0 => 'Frequent 5',
      1 => 'Occasional 4',
      2 => 'Remote 3',
      3 => 'Improbable 2',
      4 => 'Extremely Improbable 1',
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
      row_header: ['Frequent 5', 'Occasional 4', 'Remote 3', 'Improbable 2', 'Extremely Improbable 1'],
      column_header_name: 'SEVERITY',
      column_header: ['Catastrophic A', 'Hazardous B', 'Major C', 'Minor D', 'Negligible E'],
      rows: [
        ['5A',   '5B',    '5C',    '5D',    '5E'  ],
        ['4A',   '4B',    '4C',    '4D',    '4E' ],
        ['3A',   '3B',    '3C',    '3D',    '3E' ],
        ['2A',   '2B',    '2C',    '2D',    '2E' ],
        ['1A',   '1B',    '1C',    '1D',    '1E' ]
      ],
      rows_color: [
        ['red',       'red',       'red',       'yellow',    'yellow'],
        ['red',       'red',       'yellow',    'yellow',    'yellow'],
        ['red',       'yellow',    'yellow',    'limegreen', 'limegreen'],
        ['yellow',    'yellow',    'yellow',    'limegreen', 'limegreen'],
        ['limegreen', 'limegreen', 'limegreen', 'limegreen', 'limegreen']
      ],
    },

    risk_definitions: {
      red:       {rating: "HIGH",     cells: "A4, A3, B4",     description: "Cease or cut back operation promptly if necessary. Perform priority risk mitigation to ensure that additional or enhanced preventive controls are put in place to bring down the risk index to the moderate or low range."                 },
      yellow:    {rating: "MODERATE", cells: "A2, B2, C4",     description: "Schedule performance of a safety assessment to bring down the risk index to the low range if viable."   },
      limegreen: {rating: "LOW",      cells: "A1, B2, C3, D4", description: "Acceptable as is. No further risk mitigation required."                   },
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
