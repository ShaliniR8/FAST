class EULENConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Grupo Eulen',
    time_zone:                          'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    # enable_sso:                         true,
    # login_option:                       'sso',
    has_mobile_app:                     false,
    cisp_integration:                   false,
    csv_user_import:                    true,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                  false,
    allow_reopen_forms:                false,
    has_root_causes:                   false,
    global_admin_default:              false,
    advanced_checklist_data_type:      true,
    checklist_query:                   true,
    sms_im_visibility:                 false,
    safety_promotion_visibility:       true,
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


  DOCUMENT_CATEGORIES = ["Eulen Manuals", "Airlines Manuals", "Standard Operating Procedures", "Local Operating Procedures", "Safety Alerts", "Team Focus Briefs", "Other"]


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
      title: 'SEVERITY',
      orientation: :horizontal,
      direction: :left,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'CLASS',
      row_header: [
        'Aircraft Incidents',
        'People (Injury)',
        'Safety Impact',
        'Security (Threat)',
        'Environmental (Effect)',
        'Assets (Damage)',
        'Potential Increased Cost or Loss of Revenues',
        'Damage to Corporate Reputation'
      ],
      column_header_name: 'SEVERITY',
      column_header: ['5','4','3','2','1'],
      rows: [
        [ #Aircraft Incidents
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
        [ #People (Injury)
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
        [ #Safety Impact
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
        [ #Security (Threat)
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
        [ #Environmental (Effect)
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
        [ #Assets (Damage)
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
        [ #Potential Increased Cost or Loss of Revenues
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
        [ #Damage to Corporate Reputation
          'High',
          'Serious',
          'Moderate',
          'Minor',
          'Low'
        ],
      ]
    },

    severity_table_dict: {
      0 => '5',
      1 => '4',
      2 => '3',
      3 => '2',
      4 => '1'
    },

    probability_table: {
      title: 'RISK PROBABILITY',
      orientation: :vertical,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',
      row_header_name: 'Risk Probability',
      row_header: ['5 - Frequent', '4 - Probable', '3 - Occasional', '2 - Remote', '1 - Improbable'],
      column_header_name: 'CRITERIA',
      column_header: ['SAFETY', 'QUALITY ASSURANCE'],

      rows: [
        [ #A
          'Reported more than 3 times per year at a particular location',
          '5+ Multiple repeat findings (during audit and found on previous audit)',
        ],
        [ #B
          'Reported more than 3 times within the company',
          '1 - 4 Repeat Findings (on this audit and previous audit)',
        ],
        [ #C
          'Occurred in the Company',
          '3+ findings during current audit',
        ],
        [ #D
          'Known in the Aviation Industry',
          '1- 2 finding(s) during current audit',
        ],
        [ #E
          'Unknown but possible in the Aviation Industry',
          '',
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => '5 - Frequent',
      1 => '4 - Probable',
      2 => '3 - Occasional',
      3 => '2 - Remote',
      4 => '1 - Improbable'
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

      row_header_name: 'RISK PROBABILITY',
      row_header: ['5', '4', '3', '2', '1'],
      column_header_name: 'RISK SEVERITY',
      column_header: ['5','4','3','2','1'],
      rows: [
        ['25',    '20',    '15',   '10',     '5'],
        ['20',    '16',    '12',   '8',      '4'],
        ['15',    '12',    '9',    '6',      '3'],
        ['10',    '8',     '6',    '4',      '2'],
        ['5',     '4',     '3',    '2',      '1']
      ],
      rows_color: [
        ["crimson",     "crimson",      "crimson",        "crimson",        "yellow"        ],
        ["crimson",     "crimson",      "crimson",        "yellow",         "yellow"        ],
        ["crimson",     "crimson",      "yellow",         "yellow",         "mediumseagreen"],
        ["crimson",     "yellow",       "yellow",         "yellow",         "mediumseagreen"],
        ["yellow",      "yellow",       "mediumseagreen", "mediumseagreen", "mediumseagreen"],
      ],
      rows_content: [
        ['High',        'High',       'High',      'High',      'Moderate'],
        ['High',        'High',       'High',      'Moderate',  'Moderate'],
        ['High',        'High',       'Moderate',  'Moderate',  'Low'     ],
        ['High',        'Moderate',   'Moderate',  'Moderate',  'Low'     ],
        ['Moderate',    'Moderate',   'Low',       'Low',       'Low'     ]
      ]
    },


    risk_definitions: {

      # limegreen:        { rating: 'LOW',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: 'No action may be required, but risk reviewed for possible control/mitigation to ALARP',    description_approval: 'Manager or higher review and acceptance required*'                                                            },
      # steelblue:        { rating: 'MINOR',     cells: '2/4, 2/5, 3/3, 4/2, 5/2',                  description: 'Review and control/mitigate risk to ALARP',                                                description_approval: 'Senior/Regional or Program Manager or higher review and acceptance required*'                                 },
      # yellow:           { rating: 'MODERATE',  cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',           description: 'Mitigate risk to ALARP, acceptable with implementation of risk controls',                  description_approval: 'Director or higher review and acceptance required*'                                                           },
      # orange:           { rating: 'SERIOUS',   cells: '3/6, 4/5, 5/4',                            description: 'Operations may be continued, mitigation of risk to ALARP',                                 description_approval: 'Part 119 or Officer acceptance required with review and approval of Integrated Safety Committee*'             },
      # red:              { rating: 'HIGH',      cells: '4/6, 5/5, 5/6',                            description: 'Mitigation required, risk cannot be accepted',                                             description_approval: 'Review by Part 119 to determine if operations be discontinued until risk is mitigated to an acceptable level' }

      mediumseagreen:   { rating: 'Low',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',                 description: "Acceptable risk, mitigations may still be applied. Allow more than 30 days to implement", },
      yellow:           { rating: 'Moderate',  cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3, 2/4, 2/5, 3/3, 4/2, 5/2',  description: "Acceptable only with certain mitigations. Allow no more than 7 days of implementation",   },
      crimson:          { rating: 'High',      cells: '4/6, 5/5, 5/6, 3/6, 4/5, 5/4',                           description: "Unacceptable risk, intervention is required",                                             }

    },

    risk_table_index: {
      'LOW' => 'mediumseagreen',
      'MODERATE' => 'yellow',
      'HIGH' => 'crimson',
      'Low' => 'mediumseagreen',
      'Low - 1' => 'mediumseagreen',
      'Low - 2' => 'mediumseagreen',
      'Low - 3' => 'mediumseagreen',
      'Moderate' => 'yellow',
      'Moderate - 4' => 'yellow',
      'Moderate - 5' => 'yellow',
      'Moderate - 6' => 'yellow',
      'Moderate - 8' => 'yellow',
      'Moderate - 9' => 'yellow',
      'High' => 'crimson',
      'High - 10' => 'crimson',
      'High - 12' => 'crimson',
      'High - 15' => 'crimson',
      'High - 16' => 'crimson',
      'High - 20' => 'crimson',
      'High - 25' => 'crimson',
    },

    # risk_table_dict: {
    #   'mediumseagreen' => 'Low',
    #   'steelblue' => 'Minor',
    #   'yellow' => 'Moderate',
    #   'coral' => 'Serious',
    #   'crimson' => 'High',
    # }

    risk_table_dict: {
      1 => 'Low - 1',
      2 => 'Low - 2',
      3 => 'Low - 3',
      4 => 'Moderate - 4',
      5 => 'Moderate - 5',
      6 => 'Moderate - 6',
      8 => 'Moderate - 8',
      9 => 'Moderate - 9',
      10 => 'High - 10',
      12 => 'High - 12',
      15 => 'High - 15',
      16 => 'High - 16',
      20 => 'High - 20',
      25 => 'High - 25',
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

  CSV_FILE_USER_IMPORT = {
    sso_id: :email,
    filename: 'eulen_users.csv',
    prev_filename: 'eulen_users_prior.csv',
    destination_file_path:'lib/tasks',
    target_file_path: '/lib',

    # Please add clients emails
    client_emails: ['taeho.kim@prodigiq.com']
  }

end
