class RUHConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Riyadh Airports',
    time_zone:                          'Africa/Nairobi',

    # SYSTEM CONFIGS
    # enable_sso:                         true,
    # login_option:                       'sso',
    has_mobile_app:                     false,
    cisp_integration:                   false,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                  false,
    allow_reopen_forms:                false,
    has_root_causes:                   false,
    has_gmap:                          true,
    gis_layers:                        true,
    lat:                             24.958202,
    lng:                             46.700779,
    gMapZoom:                        14,
    has_confidential_forms:             true
  })


  def self.getTimeFormat
    {
      :timepicker       => 'H:i',
      :datepicker       => 'm/d/Y',
      :datetimepicker   => 'm/d/Y H:i',
      :dateformat       => '%m/%d/%Y',
      :datetimeformat   => '%m/%d/%Y %H:%M',
      :datetimezformat  => '%m/%d/%Y %H:%M %Z',
      :faa_report       => true
    }
  end

  def self.getCustomMapInfo
    # {
    #   base_directory: '/airports/RUH/',
    #   base_zoom: 15,
    #   # lat: 29.630911893011824,
    #   # lng: -95.29592674768303,
    #   maps: {
    #     main_terminal: {
    #       title: 'Main Terminal',
    #       directory: 'Main_Terminal/',
    #       zoom_max: 4,
    #       zoom_min: 1,
    #       format: 'tile_Z_X-Y.png',
    #       bounds: [7_711, 13_556]
    #     },
    #     baggage: {
    #       title: 'Baggage Level',
    #       directory: 'Terminal_Baggage_Level/',
    #       zoom_max: 4,
    #       zoom_min: 1,
    #       format: 'tile_Z_X-Y.png',
    #       bounds: [7_711, 13_556]
    #     },
    #     mezzanine: {
    #       title: 'Mezzanine Level',
    #       directory: 'Terminal_Mezzanine_Level/',
    #       zoom_max: 4,
    #       zoom_min: 1,
    #       format: 'tile_Z_X-Y.png',
    #       bounds: [7_711, 13_556]
    #     },
    #     ticket: {
    #       title: 'Ticket Level',
    #       directory: 'Terminal_Ticket_Level/',
    #       zoom_max: 4,
    #       zoom_min: 1,
    #       format: 'tile_Z_X-Y.png',
    #       bounds: [7_711, 13_556]
    #     }
    #   }
    # }
  end


  P_CODE = 'FFT671'
  CISP_TITLE_PARSE = DefaultConfig::CISP_TITLE_PARSE.deep_merge({})
  CISP_FIELD_PARSE = DefaultConfig::CISP_FIELD_PARSE.deep_merge({})

  FAA_INFO = {
    "CHDO"=>"XXX",
    "Region"=>"Anchorage",
    "ASAP MOU Holder Name"=>"Frontier",
    "ASAP MOU Holder FAA Designator"=>"BASE"
  }



  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Baseline Risk',
      mitigate_btn: 'Mitigate Risk',
      'Baseline' => 'Baseline',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY OF OCCURENCE MATRIX',
      orientation: :vertical,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',
      row_header_name: 'Outcome Definition',
      row_header: ['A - Catastrophic', 'B - Hazardous', 'C - Major', 'D - Minor', 'E - Negligible'],
      column_header_name: 'Severity',
      column_header: ['Description'],

      rows: [
        ['Multiple deaths and equipment destroyed'],
        ['Serious injuries or deaths and major equipment damage'],
        ['Injuries to people and minor equipment damage'],
        ['Minor incident introducing operating limitations or the use of emergency procedures'],
        ['No relevant occurrence'],
      ]
    },

    severity_table_dict: {
      0 => 'A - Catastrophic',
      1 => 'B - Hazardous',
      2 => 'C - Major',
      3 => 'D - Minor',
      4 => 'E - Negligible'
    },

    probability_table: {
      title: 'PROBABILITY OF OCCURRENCE MATRIX',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',
      row_header_name: 'Probability',
      row_header: ['5 - Frequent', '4 - Occasional', '3 - Remote', '2 - Improbable', '1 - Extremely Improbable'],
      column_header_name: 'Qualitative Definition',
      column_header: ['Description'],

      rows: [
        [ #5
          'Likely to occur many times (occurs frequently)'
        ],
        [ #4
          'Likely to occur sometimes (occurs infrequently)'
        ],
        [ #3
          'Unlikely, but possible to occur (occurs rarely)'
        ],
        [ #2
          'Very unlikely to occur (not known if ever)'
        ],
        [ #1
          'Almost inconceivable that the event will ever occur'
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => '5 - Frequent',
      1 => '4 - Occasional',
      2 => '3 - Remote',
      3 => '2 - Improbable',
      4 => '1 - Extremely Improbable'
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
      severity_pos: 'row',
      likelihood_pos: 'column',

      column_header_name: 'SEVERITY',
      column_header: ['A - Catastrophic', 'B - Hazardous', 'C - Major', 'D - Minor', 'E - Negligible'],
      row_header_name: 'PROBABILITY',
      row_header: ['5 - Frequent', '4 - Occasional', '3 - Remote', '2 - Improbable', '1 - Extremely Improbable'],
      rows_color: [
        ["crimson",     "crimson",          "crimson",          "yellow",           "yellow"        ],
        ["crimson",     "crimson",          "yellow",           "yellow",           "yellow"        ],
        ["crimson",     "yellow",           "yellow",           "yellow",           "mediumseagreen"],
        ["yellow",      "yellow",           "yellow",           "mediumseagreen",   "mediumseagreen"],
        ["yellow",      "mediumseagreen",   "mediumseagreen",   "mediumseagreen",   "mediumseagreen"]
      ],
      rows_content: [
        ['High',        'High',      'High',      'Moderate',    'Moderate'],
        ['High',        'High',    'Moderate',    'Moderate',    'Moderate'],
        ['High',      'Moderate',  'Moderate',    'Moderate',       'Low'  ],
        ['Moderate',  'Moderate',  'Moderate',      'Low',          'Low'  ],
        ['Moderate',    'Low',        'Low',        'Low',          'Low'  ]
      ],
      rows: [
        ['5A',     '5B',     '5C',      '5D',      '5E' ],
        ['4A',     '4B',     '4C',      '4D',      '4E' ],
        ['3A',     '3B',     '3C',      '3D',      '3E' ],
        ['2A',     '2B',     '2C',      '2D',      '2E' ],
        ['1A',     '1B',     '1C',      '1D',      '1E' ]
      ]
    },

    risk_definitions: {
      crimson:          { rating: 'High',      cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2, 4/2, 5/2',    description: 'Unacceptable under the existing circumstances' },
      yellow:           { rating: 'Moderate',  cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3, 3/6, 2/4, 2/5, 3/3',    description: 'Tolerable based on risk mitigation. It may require management decision' },
      mediumseagreen:   { rating: 'Low',       cells: '4/6, 5/5, 5/6, 4/5, 5/4',                             description: 'Acceptable' }
    },

    risk_table_index: {
      'LOW' => 'mediumseagreen',
      'Low' => 'mediumseagreen',
      'MODERATE' => 'yellow',
      'Moderate' => 'yellow',
      'HIGH' => 'crimson',
      'High' => 'crimson',
    },

    risk_table_dict: {
      'mediumseagreen' => 'Low',
      'yellow' => 'Moderate',
      'crimson' => 'High',
      '5A' => 'High',
      '5B' => 'High',
      '5C' => 'High',
      '5D' => 'Moderate',
      '5E' => 'Moderate',
      '4A' => 'High',
      '4B' => 'High',
      '4C' => 'Moderate',
      '4D' => 'Moderate',
      '4E' => 'Moderate',
      '3A' => 'High',
      '3B' => 'Moderate',
      '3C' => 'Moderate',
      '3D' => 'Moderate',
      '3E' => 'Low',
      '2A' => 'Moderate',
      '2B' => 'Moderate',
      '2C' => 'Moderate',
      '2D' => 'Low',
      '2E' => 'Low',
      '1A' => 'Moderate',
      '1B' => 'Low',
      '1C' => 'Low',
      '1D' => 'Low',
      '1E' => 'Low',
    }
  }

  def self.print_severity(owner, severity_score)
    self::MATRIX_INFO[:severity_table_dict][severity_score] unless severity_score.nil?
  end

  def self.print_probability(owner, probability_score)
    self::MATRIX_INFO[:probability_table_dict][probability_score] unless probability_score.nil?
  end

  def self.print_risk(probability_score, severity_score)
    if !probability_score.nil? && !severity_score.nil?
      lookup_table = MATRIX_INFO[:risk_table][:rows]
      return MATRIX_INFO[:risk_table_index][lookup_table[probability_score][severity_score].to_sym] rescue nil
    end
  end


end
