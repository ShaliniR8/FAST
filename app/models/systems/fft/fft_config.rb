class FFTConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Frontier Airlines',
    time_zone:                          'Mountain Time (US & Canada)',

    # SYSTEM CONFIGS
    enable_sso:                         true,
    login_option:                       'sso',
    has_mobile_app:                     true,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                  false,
    allow_reopen_forms:                false,
    has_root_causes:                   false,
  })

<<<<<<< HEAD
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
=======
  CISP_TITLE_PARSE = DefaultConfig::CISP_TITLE_PARSE.deep_merge({})
  CISP_FIELD_PARSE = DefaultConfig::CISP_FIELD_PARSE.deep_merge({})
>>>>>>> 87cf49b... Feat send report to CISP

  FAA_INFO = {
    "CHDO"=>"XXX",
    "Region"=>"Mountain",
    "ASAP MOU Holder Name"=>"Frontier",
    "ASAP MOU Holder FAA Designator"=>"BASE"
  }



  MATRIX_INFO = {
    severity_table: {
      starting_space: true,
      row_header: ['1&nbsp;Negligible','2&nbsp;Minor','3&nbsp;Moderate','4&nbsp;Critical','5&nbsp;Catastrophic'],
      column_header: ['Regulatory',"Accident/Incident/</br>Damage/OSHA",'Operational Events','Company Impact'],
      rows: [
        [ # Negligible
          "No Finding(s)",
          "No incident or damage, injury with no medical treatment",
          "Normal Operations; no effect on safety of flight or maintenance",
          "No implication to the system</br>No public relations impact"
        ],
        [ # Minor
          "General safety concern that may lead to non-compliance with Frontier policy or procedure(s)",
          "Incident with minor injury requiring minor medical treatment and/or minor damage <$50k (direct costs)",
          "Condition resulting in normal procedures with potential to impact safe operation or maintenance of an aircraft (i.e. downgrade in landing category capability); Safety margin degraded",
          "Limited/localized implication of system, occasional delays, minor loss of revenue <$50k</br>Possible public relations impact, limited resources required"
        ],
        [ # Moderate
          "Finding which results from an non-compliance with Frontier Airlines policy and/or procedures that reference regulations applicable to Frontier (i.e. a requirement derived from a directly applicable rule)",
          "Incident with injury requiring hospitalization and/or substantial aircraft/property damage <$250k (direct costs)",
          "Condition resulting in abnormal procedures with potential to impact safe operation or maintenance of an aircraft (i.e. slat disagreement, single source of electrical power, AMM deviation, parts substitution); safety incident potential",
          "Reduction of system capabilities, frequent delays or cancellations, substantial loss of revenue <$250k</br>Additional public relations efforts and resources required"
        ],
        [ # Critical
          "Finding resulting from a direct non-compliance with regulations applicable to Frontier",
          "Serious incident with serious injuries requiring hospitalization stays up to 48 hours and/or major damage to aircraft/property <$2M (direct costs)",
          "Condition resulting in abnormal procedures, impacting the continued safe operation of an aircraft (i.e. single engine operation), serious incident potential; maintenance operations suspended until resolved",
          "Partial break-down of system, schedule impact, major loss of revenue <$1M</br>Very large public relations impact requiring resources to manage information"
        ],
        [ # Catastrophic
          "Serious safety concern attributable to a direct non-compliance with regulations",
          "Accident with serious injuries requiring hospitalization over 48 hours/fatalities and/or catastrophic damage to aircraft/property >$2M (direct costs)",
          "State of emergency for an operational condition, impacting the immediate safe operation of an aircraft (i.e. dual engine failure); accident potential; maintenance operations immediately ceased",
          "Break-down of entire system for prolonged period, system-wide impact on schedules, massive loss of revenue >$1M</br>Potential for uncontrollable public relations event(s)"
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
      starting_space: true,
      row_header: [''],
      column_header: ['2&nbsp;Remote','3&nbsp;Seldom','4&nbsp;Occasional','5&nbsp;Probable','6&nbsp;Frequent'],
      rows: [
        [
          "A remote likelihood, being almost inconceivable that event will occur</br>1 in 1,000,000",
          "Very unlikely to occur</br>An activity or event that occurs intermittently</br>Regulator/Auditor have low likelihood of issue identification during any general review</br>1 in 100,000",
          "Unlikely, but possible to occur</br>Potential for infrequent occurrence. Events are sporadic in nature</br>Regulator/Auditor have low likelihood of issue identification during any general review</br>1 in 10,000",
          "Likely to occur sometimes</br>Will occur often if events follow normal patterns of process or procedure. The event is repeatable and less sporadic</br>Auditor/Regulator likely to identify issue with minimal audit activity</br>1 in 1,000",
          "Likely to occur many times and or has already been discovered (may include regulatory action already taken) by Auditor/Regulator</br>Will be continuously experienced unless action is taken to change events</br>1 in 100"
        ]
      ]
    },

    probability_table_dict: {
      0 => '2 - Remote',
      1 => '3 - Seldom',
      2 => '4 - Occasional',
      3 => '5 - Probable',
      4 => '6 - Frequent'
    },

    risk_table: {
      starting_space: true,
      row_header: ['1&nbsp;Negligible','2&nbsp;Minor','3&nbsp;Moderate','4&nbsp;Critical','5&nbsp;Catastrophic'],
      column_header: ['2&nbsp;Remote','3&nbsp;Seldom','4&nbsp;Occasional','5&nbsp;Probable','6&nbsp;Frequent'],
      rows: [
        ["limegreen",     "limegreen",    "limegreen",      "limegreen",    "limegreen"  ],
        ["limegreen",     "limegreen",    "steelblue",      "steelblue",    "yellow"     ],
        ["limegreen",     "steelblue",    "yellow",         "yellow",       "orange"     ],
        ["steelblue",     "yellow",       "yellow",         "orange",       "red"        ],
        ["steelblue",     "yellow",       "orange",         "red",          "red"        ]
      ],
      rows_content: [
        ['2',     '3',    '4',      '5',    '6'  ],
        ['4',     '6',    '8',      '10',   '12' ],
        ['6',     '9',    '12',     '15',   '18' ],
        ['8',     '12',   '16',     '20',   '24' ],
        ['10',    '15',   '20',     '25',   '30' ]
      ]
    },

    risk_definitions: {
      limegreen:        { rating: 'LOW',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: 'No action may be required, but risk reviewed for possible control/mitigation to ALARP',    description_approval: 'Manager or higher review and acceptance required*'                                                            },
      steelblue:        { rating: 'MINOR',     cells: '2/4, 2/5, 3/3, 4/2, 5/2',                  description: 'Review and control/mitigate risk to ALARP',                                                description_approval: 'Senior/Regional or Program Manager or higher review and acceptance required*'                                 },
      yellow:           { rating: 'MEDIUM',    cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',             description: 'Mitigate risk to ALARP, acceptable with implementation of risk controls',                  description_approval: 'Director or higher review and acceptance required*'                                                           },
      orange:           { rating: 'SERIOUS',   cells: '3/6, 4/5, 5/4',                            description: 'Operations may be continued, mitigation of risk to ALARP',                                 description_approval: 'Part 119 or Officer acceptance required with review and approval of Integrated Safety Committee*'             },
      red:              { rating: 'HIGH',      cells: '4/6, 5/5, 5/6',                            description: 'Mitigation required, risk cannot be accepted',                                             description_approval: 'Review by Part 119 to determine if operations be discontinued until risk is mitigated to an acceptable level' }
    },

    risk_table_index: {
      'Low - 2' => 'limegreen',
      'Low - 3' => 'limegreen',
      'Low - 4' => 'limegreen',
      'Low - 5' => 'limegreen',
      'Low - 6' => 'limegreen',
      'Low' =>  'limegreen',
      'Minor - 8' => 'steelblue',
      'Minor - 9' => 'steelblue',
      'Minor - 10' => 'steelblue',
      'Minor' => 'steelblue',
      'Medium - 12' => 'yellow',
      'Medium - 15' => 'yellow',
      'Medium - 16' => 'yellow',
      'Medium' => 'yellow',
      'Serious - 18' => 'orange',
      'Serious - 20' => 'orange',
      'Serious' => 'orange',
      'High - 24' => 'red',
      'High - 25' => 'red',
      'High - 30' => 'red',
      'High' => 'red',
    },

    risk_table_dict: {
      2 => 'Low - 2',
      3 => 'Low - 3',
      4 => 'Low - 4',
      5 => 'Low - 5',
      6 => 'Low - 6',
      8 => 'Minor - 8',
      9 => 'Minor - 9',
      10 => 'Minor - 10',
      12 => 'Medium - 12',
      15 => 'Medium - 15',
      16 => 'Medium - 16',
      18 => 'Serious - 18',
      20 => 'Serious - 20',
      24 => 'High - 24',
      25 => 'High - 25',
      30 => 'High - 30',
    }
  }

  ULTIPRO_DATA = {
    upload_path: '/var/sftp/fftftpuser/ProSafeT_User_List_04082020.XML',
    expand_output: false, #Shows full account generation details
    dry_run: false, #Prevents the saving of data to the database

    #The following identifies what account type is associated with each employee-group
    group_mapping: {
      'dispatch'    => 'Analyst',
      'fight-crew'  => 'Pilot',
      'ground'      => 'Ground',
      'maintenance' => 'Staff',
      'other'       => 'Staff'
    }, #Cabin
    tracked_privileges: [
      'Flight Operations: Incident Submitter',
      'Flight Operations: ASAP Submitter',
      'Flight Operations: Fatigue Submitter',
      'Flight Operations: Medical Event Submitter',
      'Flight Operations: Fume Event Submitter',
      'Inflight: Incident Submitter',
      'Inflight: ASAP Submitter',
      'Inflight: Fatigue Submitter',
      'Inflight: Medical Event Submitter',
      'Inflight: Fume Event Submitter',

      'Ground: Incident Submitter',
      'Ground: General Submitter',
      'Other: General Submitter',
      'Flight Crew: ASAP Submitter',
      'Flight Crew: Incident Submitter',
      'Flight Crew: Fatigue Submitter',
      'Dispatch: ASAP Submitter',
      'Dispatch: Incident Submitter',
      'Dispatch: Fatigue Submitter',
      'Maintenance: ASAP Submitter',
      'Maintenance: Incident Submitter',
      'Maitnenance: Fatigue Submitter',
      'Cabin: ASAP Submitter',
      'Cabin: Incident Submitter',
      'Cabin: Fatigue Submitter'
    ],
  }


end
