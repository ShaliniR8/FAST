class RJETConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Republic Airways',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:               true,
    enable_sso:                   true,
    login_option:                 'dual',
    cisp_integration:             true,
    csv_user_import:              true,
    asrs_integration:             true,

    # TO BE REMOVED
    base_risk_matrix:             false,
    has_verification:             true,
    hazard_root_cause_lock:       false,
    global_admin_default:         false,
    sabre_integration:            true,
  })

  # CISP INTEGRATION
  # P_CODE = 'RPA574' # for RPA (Republic)
  # P_CODE = 'L8T5A3 '# for LTA (Lift)

  P_CODE = {
    'Flight Ops ASAP' => 'RPA574',
    'Dispatch ASAP'   => 'RPA574',
    'LIFT Pilot VSRP' => 'L8T5A3'
  }

  AIRLINE_ID = {
    'Flight Ops ASAP' => 'RPA',
    'Dispatch ASAP'   => 'RPA',
    'LIFT Pilot VSRP' => 'LTA'
  }

  CISP_TITLE_PARSE = {
    'Flight Ops ASAP' => 'flightcrew',
    'Dispatch ASAP'   => 'dispatch',
    'LIFT Pilot VSRP' => 'pilot vsrp',
  }

  CISP_FIELD_PARSE = {
    'Flight Ops ASAP' => {
      'Event Details - Provide the facts about the events or hazard here.' => {
        'flightNumber'  => 'Flight Number',
        'departure'     => 'Departure Airport',
        'arrival'       => 'Destination Airport',
        'flightPhase'   => 'Operational Phase'
      },
      "Narrative - Provide the facts about 'WHAT' happened here." => {
        'eventDescription' => '',
      }
    },
    'Dispatch ASAP' => {
      'Details' => {
        'flightNumber'  => 'Flight Number',
        'departure'     => 'Departure Airport',
        'arrival'       => 'Destination Airport',
      },
      'Description of the Event or Safety Concern' => {
        'eventDescription' => '',
      },
    },
    'LIFT Pilot VSRP' => {
      'Event Details' => {
        'flightNumber'  => 'Flight Number',
        'aircraftType'  => 'Tail Number',
        'location'  => 'Location',
      },
      'Description' => {
        'eventDescription' => '',
      },
    },
  }

  # SABRE INTEGRATION
  SABRE_MAPPABLE_FIELD_OPTIONS = {
    "Flight Date"        => "flight_date",
    "Flight Number"      => "flight_number",
    "Tail Number"        => "tail_number",
    "Departure Airport"  => "departure_airport",
    "Arrival Airport"    => "arrival_airport",
    "Landing Airport"    => "landing_airport",
    "Captain"            => "ca",
    "First Officer"      => "fo",
    "Flight Attendant 1" => "fa_1",
    "Flight Attendant 2" => "fa_2"
  }

  FAA_INFO = {
    "CHDO"=>"Indianapolis CMO",
    "Region"=>"Midwest Region",
    "ASAP MOU Holder Name"=>"Leon Hayes",
    "ASAP MOU Holder FAA Designator"=>"James Brannon"
  }

  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Initial Risk',
      mitigate_btn: 'Mitigated Risk',
      'Baseline' => 'Initial',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY TABLE',

      orientation: :vertical,
      direction: :down,
      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'SEVERITY',
      row_header: ['1&nbsp;Negligible','2&nbsp;Minor','3&nbsp;Moderate','4&nbsp;Critical','5&nbsp;Catastrophic'],
      column_header_name: 'CATEGORY',
      column_header: ['Regulatory',"Accident/Incident,</br>A/C Damage,OSHA",'Operational Events','Systemic Impact','Reactive Only'],
      rows: [
        [ # Negligible
          "No Findings.",
          "No incident or damage; injury with no medical treatment.",
          "Normal Operations; no effect on safety of flight.",
          "No implication of Company, costs <$50k.",
          "Negligible"
        ],
        [ # Minor
          "General safety concern that may lead to non-compliance with Company policy or procedure(s).",
          "Incident with minor injury requiring minor medical treatment; minor aircraft/property damage.",
          "Event resulting in normal conditions with potential to impact safe operation of an aircraft, safety margin degraded.",
          "Limited/localized implication of company, occasional delays, minor increase in costs <250k.",
          "Minor"
        ],
        [ # Moderate
          "Finding which results from a non-compliance with Company policy and procedures that reference regulations applicable to the Company (i.e. a requirement derived from a directly applicable rule)",
          "Incident with injury requiring hospitalization; moderate aircraft/property damage.",
          "Event resulting in abnormal conditions with potential to impact safe operation of an aircraft; Safety incident potential.",
          "Regional implication, frequent delays or cancellation, substantial increase in costs <$1M.",
          "Moderate"
        ],
        [ # Critical
          "Finding which results from a direct non-compliance with regulations applicable to the company that could affect safety of flight.",
          "Serious incident with serious injuries; substantial aircraft/property damage.",
          "Event resulting in abnormal conditions, impacting the continued safe operation of an aircraft, serious incident potential.",
          "National implication, partial regional schedule impact, major increase in costs <$10M.",
          "Critical"
        ],
        [ # Catastrophic
          "Serious safety concern attributable to a direct non-compliance with regulations that will affect safety of flight.",
          "Accident with serious injuries/fatalitites; catastrophic damage to aircraft/property.",
          "State of emergency for an operational condition, impacting the immediate safe operation of an aircraft; Accident potential.",
          "International implication, systemwide impact on schedules, massive in costs >$10M.",
          "Catastrophic"
        ]
      ]
    },

    severity_table_dict: {
      0 => '1 - Negligible',
      1 => '2 - Minor',
      2 => '3 - Moderate',
      3 => '4 - Critical',
      4 => '5 - Catastrophic'
    },

    probability_table: {
      title: 'LIKELIHOOD TABLE',

      orientation: :horizontal,
      direction: :right,
      size: 'col-xs-12 col-sm-12 col-md-12 col-lg-12',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: '',
      row_header: [''],
      column_header_name: 'LIKELIHOOD',
      column_header: ['1&nbsp;Reactive Only','2&nbsp;Remote','3&nbsp;Seldom','4&nbsp;Occasional','5&nbsp;Probable','6&nbsp;Frequent'],
      rows: [
        [
          "<b>Reactive Only</b>",
          "<ul><li>A remote likelihood, being almost inconceivable that event will occur</li><li><1 occurrence in 10 years at the Company</li></ul>",
          "<ul><li>Very unlikely to occur</li><li>An activity or event that occurs intermittently</li><li>Regulator/Auditor have low likelihood of issue identification during any general or focused review</li><li>≥1 occurrence in 10 years, but <1 occurrence in 2 years</li></ul>",
          "<ul><li>Unlikely, but possible to occur</li><li>Potential for infrequent occurrence. Events are sporadic in nature</li><li>Auditor/Regulator have potential of issue discovery during focused or specialized review</li><li>≥1 occurrence in 2 years, but <1 occurrence every year</li></ul>",
          "<ul><li>Likely to occur sometimes</li><li>Will occur often if events follow normal patterns of process or procedure. The event is repeatable and less sporadic</li><li>Auditor/Regulator likely to identify issue with minimal audit activity</li><li>≥1 occurrence every a year, but <1 occurrence every month</li></ul>",
          "<ul><li>Likely to occur many times</li><li>Will be continuously experienced unless action is taken to change events</li><li>>12 times a year (more than once a month)</li></ul>"
        ]
      ]
    },

    probability_table_dict: {
      0 => '1 - Reactive Only',
      1 => '2 - Remote',
      2 => '3 - Seldom',
      3 => '4 - Occasional',
      4 => '5 - Probable',
      5 => '6 - Frequent'
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

      row_header_name: 'SEVERITY',
      row_header: ['1&nbsp;Negligible','2&nbsp;Minor','3&nbsp;Moderate','4&nbsp;Critical','5&nbsp;Catastrophic'],
      column_header_name: 'LIKELIHOOD',
      column_header: ['1&nbsp;Reactive Only','2&nbsp;Remote','3&nbsp;Seldom','4&nbsp;Occasional','5&nbsp;Probable','6&nbsp;Frequent'],
      rows: [
        ['1',     '2',     '3',    '4',      '5',    '6'  ],
        ['2',     '4',     '6',    '8',      '10',   '12' ],
        ['3',     '6',     '9',    '12',     '15',   '18' ],
        ['4',     '8',     '12',   '16',     '20',   '24' ],
        ['5',     '10',    '15',   '20',     '25',   '30' ]
      ],

      rows_color: [
        ["limegreen",     "limegreen",     "limegreen",    "limegreen",      "limegreen",    "limegreen"  ],
        ["limegreen",     "limegreen",     "limegreen",    "limegreen",      "yellow",       "yellow"     ],
        ["limegreen",     "limegreen",     "yellow",       "yellow",         "orange",       "orange"     ],
        ["limegreen",     "limegreen",     "yellow",       "orange",         "orange",       "red"        ],
        ["limegreen",     "yellow",        "orange",       "orange",         "red",          "red"        ]
      ]
    },

    risk_definitions: {
      limegreen:        { rating: 'Low',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: 'Risks in this region may be accepted without further action. However, continuous analysis or trending may be appropriate to accurately monitor risk. Manager or higher acceptance is required for all risk determinations or mitigations that fall within Green region.' },
      yellow:           { rating: 'Medium',    cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',             description: 'Actual hazards with risks falling in this region are acceptable with risk controls and monitoring. If risk controls are not possible, monitoring must be applied to ensure the risk does not elevate. Director or higher acceptance is required for risks falling within the Yellow region.' },
      orange:           { rating: 'Serious',   cells: '3/6, 4/5, 5/4',                            description: 'Actual hazards with risks falling in this region are generally unacceptable although operation is allowed to continue while a high priority, systemic mitigation strategy is carried out. An immediate interim mitigation action must be carried out prior to a compressive fix. Designated 14 CFR Part 119 personnel are responsible for mitigation strategies. If the risk cannot be mitigated to a lower risk region, managing directors and above can accept the risk. When senior management accepts a risk in the orange region, 14 CFR Part 119 personnel must monitor to ensure risk does not elevate.' },
      red:              { rating: 'High',      cells: '4/6, 5/5, 5/6',                            description: 'Actual hazards with risks falling in this region require immediate action to eliminate the hazard or control the factors leading to its higher likelihood or severity. Operation must not begin or continue without mitigation to as low as reasonably practicable (ALARP) risk level, provided it is in a lower risk region. Designated 14 CFR Part 119 personnel are responsible for mitigation strategies; however, the Accountable Executive must review and approve mitigations from the Red region to a lower risk region.' }
    },

    risk_table_index: {
      'Low - 1' => 'limegreen',
      'Low - 2' => 'limegreen',
      'Low - 3' => 'limegreen',
      'Low - 4' => 'limegreen',
      'Low - 5' => 'limegreen',
      'Low - 6' => 'limegreen',
      'Low - 8' => 'limegreen',
      'Low' =>  'limegreen',
      'LOW' =>  'limegreen',
      'Medium - 9' => 'yellow',
      'Medium - 10' => 'yellow',
      'Medium - 12' => 'yellow',
      'Medium' => 'yellow',
      'MEDIUM' => 'yellow',
      'Serious - 15' => 'orange',
      'Serious - 16' => 'orange',
      'Serious - 18' => 'orange',
      'Serious - 20' => 'orange',
      'Serious' => 'orange',
      'SERIOUS' => 'orange',
      'High - 24' => 'red',
      'High - 25' => 'red',
      'High - 30' => 'red',
      'High' => 'red',
      'HIGH' => 'red',
    },

    risk_table_dict: {
      1 => 'Low - 1',
      2 => 'Low - 2',
      3 => 'Low - 3',
      4 => 'Low - 4',
      5 => 'Low - 5',
      6 => 'Low - 6',
      8 => 'Low - 8',
      9 => 'Medium - 9',
      10 => 'Medium - 10',
      12 => 'Medium - 12',
      15 => 'Serious - 15',
      16 => 'Serious - 16',
      18 => 'Serious - 18',
      20 => 'Serious - 20',
      24 => 'High - 24',
      25 => 'High - 25',
      30 => 'High - 30',
    }
  }

  # NASA_ASRS = {
  #   templates: [
  #     'LIFT Pilot VSRP'
  #   ]
  # }

  NASA_ASRS = {
    airline_number: 313,
    templates: {
      'Flight Ops ASAP'       => :fosap,
      'Dispatch ASAP'         => :dsap,
      'Maintenance ASAP'      => :msap,
      'Inflight ASAP'         => :isap,
      'LIFT Pilot VSRP'       => :lpvsrp,
      'LIFT Maintenance VSRP' => :lmvsrp
    }
  }

  CSV_FILE_USER_IMPORT = {
    sso_id: :email,
    filename: 'RepublicUserAccountsMaster.csv',
    prev_filename: 'RepublicUserAccountsMaster_prior.csv',
    destination_file_path:'lib/tasks',
    target_file_path: '/var/sftp/rjetsftpuser',

    # Please add clients emails
    client_emails: ['WIT@rjet.com', 'Jennifer.Hoagland@rjet.com', 'Haley.Myers@rjet.com', 'Kayse.Calton@rjet.com']
  }
end
