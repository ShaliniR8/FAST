class SJOConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Juan Santamaría International Airport',
    time_zone:                          'America/Costa_Rica',

    # SYSTEM CONFIGS
    # enable_sso:                         true,
    # login_option:                       'sso',
    has_mobile_app:                     false,
    cisp_integration:                   false,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                  false,
    allow_reopen_forms:                false,
    has_root_causes:                   false,
    global_admin_default:              false,
    sms_im_visibility:                 false,
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
      size: 'col-xs-8',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      column_header_name: '',
      column_header: ['A&nbsp;Catastrophic','B&nbsp;Hazardous','C&nbsp;Major','D&nbsp;Minor','E&nbsp;Negligible'],
      row_header_name: 'SEVERITY',
      row_header: [
        'MEANING',
      ],
      rows: [
        [ 
          'Aircraft/equipment desrtroyed
            <br><br>
            Multiple deaths',
          'A large reduction in safety margins, physical distress or a workload such that operational personnel cannot be relied upon to perform their tasks accurately or completely.
            <br><br>
            Serious injury 
            <br><br>
            Major equipment damage',
          'A significant reduction in safety margins, a reduction in the ability operational personnel to cope with adverse operating conditions as a result of an increase in workload or as a result of conditions impairing their efficiency.
            <br><br> 
            Serious incident
            <br><br>
            Injury to persons',
          'Nuisance 
            <br><br> 
            Operating limitations 
            <br><br>
            Use of emergency procedures 
            <br><br>
            Minor incident',
          'Few consequences'
        ]
      ] #End of rows
    },

    severity_table_dict: {
      0 => '1',
      1 => '2',
      2 => '3',
      3 => '4',
      4 => '5'
    },

    probability_table: {
      title: 'PROBABILITY EXERCISE',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-4',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: 'PROBABILITY',
      row_header: ['5&nbsp;Frequent', '4&nbsp;Occasional', '3&nbsp;Remote', '2&nbsp;Improbable', '1&nbsp;Extremely improbable'],
      column_header_name: '',
      column_header: ['MEANING'],
      rows: [
        [
          "Likely to occur many times (has occurred frequently)"
        ],
        [
          "Likely to occur sometimes (has occurred infrequently)"
        ],
        [
          "Unlikely to occur, but possible (has occurred rarely)"
        ],
        [
          "Very unlikely to occur (not known to have occurred)"
        ],
        [
          "Almost inconcievable that the event will occur"
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D'
    },

    risk_table: {
      title: 'RISK ASSESSMENT MATRIX',

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
      column_header: ['A&nbsp;Catastrophic','B&nbsp;Hazardous','C&nbsp;Major','D&nbsp;Minor','E&nbsp;Negligible'],
      row_header_name: 'PROBABILITY',
      row_header: ['5&nbsp;Frequent', '4&nbsp;Occasional', '3&nbsp;Remote', '2&nbsp;Improbable', '1&nbsp;Extremely improbable'],

      rows_color: [
        ["crimson",   "crimson",          "crimson",            "yellow",         "yellow"          ],
        ["crimson",   "crimson",          "yellow",             "yellow",         "yellow"          ],
        ["crimson",   "yellow",           "yellow",             "yellow",         "mediumseagreen"  ],
        ["yellow",    "yellow",           "yellow",             "mediumseagreen", "mediumseagreen"  ],
        ["yellow",    "mediumseagreen",   "mediumseagreen",     "mediumseagreen", "mediumseagreen"  ],
      ],
    },

    risk_table_index: {
      "INTOLERABLE" => 'crimson',
      "TOLERABLE" => 'yellow',
      "ACCEPTABLE" => 'mediumseagreen'
    },

    risk_table_dict: {
      crimson:        "INTOLERABLE",
      yellow:         "TOLERABLE",
      mediumseagreen: "ACCEPTABLE",
    },

    risk_definitions: {
      crimson:          { rating: 'INTOLERABLE',      cells: 'A/1, A/2, and B/1',                description: 'Acceptable as is. No further safety risk mitigation required.' },
      yellow:           { rating: 'TOLERABLE',  cells: 'A/4, B/3, and D/1',                      description: 'Can be tolerated based on the safety risk mitigation. It may require management decision to accept the risk.' },
      mediumseagreen:   { rating: 'ACCEPTABLE',       cells: 'A/5, B/5, C/4, C/5, D/3, D/4, and D/5',   description: 'Take immediate action to mitigate the risk or stop the activity. Perform priority safety risk mitigation to ensure additional or enhanced preventative controls are in place to bring down the safety risk index to tolerable.' }
    },

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
