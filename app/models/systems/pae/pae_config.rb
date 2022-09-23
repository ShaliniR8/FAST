class PAEConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Paine Field Airport',
    time_zone:                    'Pacific Time (US & Canada)',

    # SYSTEM CONFIGS    
    has_gmap:                      true,
    gis_layers:                    true,

    lat:                           47.90885,
    lng:                           -122.28128,
    gMapZoom:                      14,

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

      row_header_name: ' ',
      row_header: [
        'CLASS'
      ],
      column_header_name: 'SEVERITY',
      column_header: ['Minimal', 'Minor', 'Major', 'Hazardous', 'Catastrophic'],
      rows: [
        [ 'A', 'B', 'C', 'D', 'E'],
      ]
    },

    severity_table_dict: {
      0 => 'Minimal A',
      1 => 'Minor B',
      2 => 'Major C',
      3 => 'Hazardous D',
      4 => 'Catastrophic E',
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
      row_header: ['Frequent', 'Probable', 'Remote', 'Extremely Remote', 'Extremely Improbable'],
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
      1 => 'Probable 4',
      2 => 'Remote 3',
      3 => 'Extremely Remote 2',
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
      row_header: ['Frequent 5', 'Probable 4', 'Remote 3', 'Extremely Remote 2', 'Extremely Improbable 1'],
      column_header_name: 'SEVERITY',
      column_header: ['Minimal A', 'Minor B', 'Major C', 'Hazardous D', 'Catastrophic E'],
      rows: [
        ['5A',   '5B',    '5C',    '5D',    '5E'  ],
        ['4A',   '4B',    '4C',    '4D',    '4E' ],
        ['3A',   '3B',    '3C',    '3D',    '3E' ],
        ['2A',   '2B',    '2C',    '2D',    '2E' ],
        ['1A',   '1B',    '1C',    '1D',    '1E' ]
      ],
      rows_color: [
        ['orange',       'orange',     'red',         'red',      'red'],
        ['yellow',       'yellow',     'orange',      'red',      'red'],
        ['limegreen',    'yellow',     'orange',      'orange',   'red'],
        ['limegreen',    'limegreen',  'yellow',      'orange',   'orange'],
        ['limegreen',    'limegreen',  'limegreen',   'yellow',   'yellow']
      ],
    },

    risk_definitions: {
      red:       {rating: "Extreme Risk",      description: "Unacceptable under existing circumstances, requires immediate decision by Accountable Executive"   },
      orange:    {rating: "Substantial Risk",  description: "Manageable under risk control and migration. Requires operational review by Safety Committee"   },
      yellow:    {rating: "Moderate Risk",     description: "Acceptable after review of the operation by SMS Coordinator. Requires continued tracking and recorded action plans."   },
      limegreen: {rating: "Minimal Risk",      description: "Acceptable with consistent data collection and continuous monitoring. Proceed with operation/acitivity"   },
    },

    risk_table_index: {
      'Extreme Risk'      => 'red',
      'Substantial Risk'  => 'orange',
      'Moderate Risk'     => 'yellow',
      'Minimal Risk'      => 'limegreen'
    },

    risk_table_dict: {
      red:        'Extreme Risk',
      orange:     'Substantial Risk',
      yellow:     'Moderate Risk',
      limegreen:  'Minimal Risk'
    }
  }
end
