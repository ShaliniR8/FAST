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
      baseline_btn: 'Initial Risk',
      mitigate_btn: 'Mitigated Risk',
      'Baseline' => 'Initial',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'Severity Table',

      orientation: :vertical,
      direction: :down,
      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'SEVERITY',
      row_header: ['A&nbsp;Catastrophic','B&nbsp;Hazardous','C&nbsp;Major','D&nbsp;Minor', 'E&nbsp;Negligible'],
      column_header_name: 'MEANING',
      column_header: [''],

      rows: [
        [ #Catastrophic
          "<div style = 'width: 300px; margin: auto;'>
              Aircraft/equipment desrtroyed
              <br><br>
              Multiple deaths
            </div>" 
        ],
        [ #Hazardous
          "<div style = 'width: 300px; margin: auto;'>
            A large reduction in safety margins, physical distress or a workload such that operational personnel cannot be relied upon to perform their tasks accurately or completely.
            <br><br>
            Serious injury 
            <br><br>
            Major equipment damage
          </div>" 
        ],
        [ # Major
          "<div style = 'width: 300px; margin: auto;'>
            A significant reduction in safety margins, a reduction in the ability operational personnel to cope with adverse operating conditions as a result of an increase in workload or as a result of conditions impairing their efficiency.
            <br><br> 
            Serious incident
            <br><br>
            Injury to persons
          </div>" 
        ],
        [ # Minor
          "<div style = 'width: 300px; margin: auto;'>
            Nuisance 
            <br><br> 
            Operating limitations 
            <br><br>
            Use of emergency procedures 
            <br><br>
            Minor incident
          </div>"          
        ],
        [ # Negligible
          "<div style = 'width: 300px; margin: auto;'>
            Few consequences
          </div>"
        ]
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
      title: 'LIKELIHOOD TABLE',

      orientation: :vertical,
      direction: :down,
      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: 'LIKELIHOOD',
      row_header: ['5&nbsp;Frequent', '4&nbsp;Occasional', '3&nbsp;Remote', '2&nbsp;Improbable', '1&nbsp;Extremely improbable'],
      column_header_name: 'MEANING',
      column_header: [''],
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
      ]
    },

    probability_table_dict: {
      0 => '5 - Frequent',
      1 => '4 - Occasional',
      2 => '3 - Remote',
      3 => '2 - Improbable',
      4 => '1 - Extremely Improbable',
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

      row_header_name: 'LIKELIHOOD',
      row_header: ['5&nbsp;Frequent','4&nbsp;Occasional','3&nbsp;Remote','2&nbsp;Improbable','1&nbsp;Extremely improbable'],
      column_header_name: 'SEVERITY',
      column_header: ['A&nbsp;Catastrophic','B&nbsp;Hazardous','C&nbsp;Major','D&nbsp;Minor','E&nbsp;Negligible'],
      rows: [
        ['5',     '5',     '5',    '5',      '5' ],
        ['4',     '4',     '4',    '4',      '4' ],
        ['3',     '3',     '3',    '3',      '3' ],
        ['2',     '2',     '2',    '2',      '2' ],
        ['1',     '1',     '1',    '1',      '1' ]
      ],

      rows_color: [
        ["red",     "red",        "red",      "yellow",    "yellow"   ],
        ["red",     "red",        "yellow",   "yellow",    "yellow"   ],
        ["red",     "yellow",     "yellow",   "yellow",    "limegreen"],
        ["yellow",  "yellow",     "yellow",   "limegreen", "limegreen"],
        ["yellow",  "limegreen",  "limegreen","limegreen", "limegreen"]
      ]
    },

    risk_definitions: {
      limegreen:        { rating: 'ACCEPTABLE',      cells: '5/2, 5/3, 5/4, 5/5, 4/4, 4/5, 3/5',                                description: 'Acceptable as is. No further safety risk mitigation required.' },
      yellow:           { rating: 'TOLERABLE',       cells: '1/4, 1/5, 2/3, 2/4, 2/5, 3/2, 3/3, 3/4, 4/1, 4/2, 4/3, 5/1',       description: 'Can be tolerated based on the safety risk mitigation. It may require management decision to accept the risk.' },
      red:              { rating: 'INTOLERABLE',     cells: '1/1, 1/2, 1/3, 1/4, 1/5, 2/1',                                     description: 'Take immediate action to mitigate the risk or stop the activity. Perform priority safety risk mitigation to ensure additional or enhanced preventative controls are in place to bring down the safety risk index to tolerable.' }
    },

    #double check this one

    risk_table_index: {
      'Low - 1' => 'limegreen',
      'Low - 2' => 'limegreen',
      'Low' =>  'limegreen',
      'LOW' =>  'limegreen',
      'Medium - 2' => 'yellow',
      'Medium - 3' => 'yellow',
      'Medium' => 'yellow',
      'MEDIUM' => 'yellow',
      'High - 4' => 'red',
      'High - 5' => 'red',
      'High' => 'red',
      'HIGH' => 'red',
    },

    risk_table_dict: {
      1 => 'Low - 1',
      2 => 'Low - 2',
      3 => 'Medium - 3',
      4 => 'High - 4',
      5 => 'High - 5',
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
