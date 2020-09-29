class ATNConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Air Transport International',
    time_zone:                          'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:                     true,
    cisp_integration:                   true,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                   false,
  })

  P_CODE = 'A9T2N7'
  CISP_TITLE_PARSE = DefaultConfig::CISP_TITLE_PARSE.deep_merge({})
  CISP_FIELD_PARSE = DefaultConfig::CISP_FIELD_PARSE.deep_merge({
    'Flight Crew ASAP' => {
      'Narratives' => {
        'eventDescription' => "Describe the Event",
      }
    }
  })

  FAA_INFO = DefaultConfig::FAA_INFO.merge({ #CORRECT/REVISE
    'CHDO'=>'Minneapolis-St. Paul FSDO, 6020 28th Avenue South, Minneapolis, MN 55450',
    'Region'=>'Great Lakes',
    'ASAP MOU Holder Name'=>'N/A',
    'ASAP MOU Holder FAA Designator'=>'SCNA'
  })

  RISK_MATRIX = {
    # :likelihood       => ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
    # :severity         => (0..4).to_a.reverse,
    :risk_factor      => {"LOW" => "limegreen", "MINOR" => "steelblue", "MEDIUM" => "yellow", "SERIOUS" => "orange", "HIGH" => "red"},
  }

  MATRIX_INFO = {
    severity_table: {
      title: 'SEVERTIY EXERCISE',

      orientation: :vertical,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'SEVERITY',
      row_header: ['I','II','III','IV'],
      column_header_name: 'CATEGORY',
      column_header: ['Consequence','or','or','or','or'],
      rows: [
        [ # I
          "Event or circumstance with potentially disastrous impact on business or significant material impact on a key area",
          "Long term damage to reputation. Sustained negative media attention, brand and/or image affected nationally and/or internationally",
          "Huge financial loss - Significant budget overrun with no capacity to adjust within existing budget.",
          "Major regulatory deviation, operating an aircraft in an unsafe and non-standard condition. Loss of company approvals, permits or certificates, resulting in suspension of all operation",
          "Aircraft accident or other accidents with serious injuries, fatalities or significant damage, death or total disability of an employee."
        ],
        [ # II
          "Critical event or circumstance that will have some impact on business",
          "Sustained damage to brand / image or reputation nationally or locally - Adverse national or local media.",
          "Major financial loss - Requires significant adjustment to approved / funded projects / programs",
          "Moderate regulatory deviation, operating an aircraft in an unsafe and non-standard condition.",
          "Aircraft incident or other incidents with serious injuries and/ or moderate damage"
        ],
        [ # III
          "Event that can be readily absorbed but requires management effort to minimize the impact",
          "Deficiencies leading to poor dependability or disruption to schedules, some short term negative media coverage.",
          "Some financial loss, requires monitoring & possible corrective action.",
          "Minor regulatory deviation, returning an aircraft to service in an un-airworthy condition.",
          "Incident with minor injury and/or minor aircraft damage."
        ],
        [ # IV
          "Some loss but not material, existing controls and procedures should cope with the event or circumstance.",
          "Negligible impact on delivery of service",
          "Unlikely to impact budget or funded activities, minor or no damage to brand, image or reputation.",
          "Policy and/or procedure deviation, affecting aircraft or systems reliability above established control limits.",
          "Less than minor injury and/or less than minor system damage"
        ],
      ]
    },

    severity_table_dict: {
      0 => 'I',
      1 => 'II',
      2 => 'III',
      3 => 'IV',
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
      row_header: ['A - Frequent','B - Probable','C - Occasional','D - Remote'],
      column_header_name: 'CRITERIA',
      column_header: ['Fleet/System/Inventory','Specific Individual Item 1','Specific Individual Item 2'],

      rows: [
        [
          "It is expected to occur in most circumstances.",
          "There is a strong likelihood of the hazards reoccurring",
          "Likely to occur often in the life of an item, with a probability of occurence 80\%+"
        ],
        [
          "Similar hazards have been recorded on a regular basis",
          "Considered that it is likely that the hazard could occur",
          "Will occur several times in the life of an item, with a probability of occurrence less than 80\% but greater than 50\%."
        ],
        [
          "Very few known incidents of occurrence / Unlikely, but can expect to occur",
          "Has not occurred yet, but it could occur sometime.",
          "Likely to occur some time in the life of an item, with a probability of occurrence less than 50\% but greater than 20\%."
        ],
        [
          "No known or recorded incidents of occurrence",
          "Remote chance, may only occur in exceptional circumstance",
          "Unlikely but possible to occur in the life of an item, with a probability of occurrence less than 20\%"
        ]
      ]
    },

    probability_table_dict: {
      0 => 'A - Frequent',
      1 => 'B - Probable',
      2 => 'C - Occasional',
      3 => 'D - Remote',
    },

    risk_table: {
      title: 'RISK ASSESSMENT MATRIX',

      size: 'col-xs-6',
      title_style: 'matrixTitle',
      main_header_style: 'matrixMainHeader',
      header_style: 'matrixHeader',
      cell_name: 'risk_td',

      row_header_name: 'PROBABILITY',
      row_header: ['A','B','C','D'],
      column_header_name: 'SEVERITY',
      column_header: ['I','II','III','IV'],

      rows_color: [
        ["red",     "red",       "orange",      "yellow"      ],
        ["red",     "orange",    "yellow",      "steelblue"   ],
        ["orange",  "yellow",    "steelblue",   "limegreen"   ],
        ["yellow",  "steelblue", "limegreen",   "limegreen"   ]
      ],

      rows: [
        ['1',     '1',     '2',      '3' ],
        ['1',     '2',     '3',      '4' ],
        ['2',     '3',     '4',      '5' ],
        ['3',     '4',     '5',      '5' ]
      ]
    },

    risk_definitions: {
      limegreen:        { rating: 'LOW',       cells: '3/5, 4/4, 4/5',       description: 'Review by appropriate authority to evaluate if corrective and/or preventive action is required.' },
      steelblue:        { rating: 'MINOR',     cells: '2/4, 2/5, 3/3',       description: 'Review by appropriate authority. May require tracking and corrective and/or preventive action.' },
      yellow:           { rating: 'MEDIUM',    cells: '1/5, 2/4, 3/3, 4/2',  description: 'Review by appropriate authority, requires tracking and probable corrective and/or preventive action.' },
      orange:           { rating: 'SERIOUS',   cells: '1/4, 2/3, 3/2',       description: 'Unacceptable, requires investigation, resources and corrective and/or preventive action.' },
      red:              { rating: 'HIGH',      cells: '1/2, 1/3, 2/2',       description: 'Unacceptable, requires the highest priority for investigation, resources and corrective and/or preventive action.' }
    },

    risk_table_index: {
      'Low - 5' => 'limegreen',
      'Minor - 4' => 'steelblue',
      'Medium - 3' => 'yellow',
      'Serious - 2' => 'orange',
      'High - 1' => 'red',
    },

    risk_table_dict: {
      5 => 'Low - 5',
      4 => 'Minor - 4',
      3 => 'Medium - 3',
      2 => 'Serious - 2',
      1 => 'High - 1',
    }
  }




  ULTIPRO_DATA = {
    upload_path: '/var/sftp/scxsftpuser/Suncountry_POC.xml',
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
