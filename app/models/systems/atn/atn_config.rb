class ATNConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Air Transport International',
    time_zone:                          'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:                     true,
    cisp_integration:                   true,
    add_attachment_in_any_status:       true,
    global_admin_default:               false,
    add_attachment_in_any_status:       true,
    advanced_checklist_data_type:       true,
    checklist_query:                    true,
    hide_submission_in_dashboard:       true,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                   false,
  })


  P_CODE = {
    'ASAP - Flight' => 'A9T2N7'
  }

  AIRLINE_ID = {
    'ASAP - Flight' => 'ATN',
  }

  CISP_TITLE_PARSE = {
    'ASAP - Flight'   => 'flightcrew',
  }
  CISP_FIELD_PARSE = {
    'ASAP - Flight' => {
      'Event Information' => {
        'flightNumber'  => 'Flight Number',
        'departure'     => 'Departure Airport',
        'arrival'       => 'Landing Airport',
        'flightPhase'   => 'Phase of Flight'
      },
      'Narratives' => {
        'eventDescription' => "Describe the Event",
      }
    }
  }

  FAA_INFO = {
    'CMO'=>'DFW Certificate Management Office, 8700 Freeport Parkway, Suite 200A, Irving, TX 75063',
    'Region'=>'SW',
    'ASAP MOU Holder Name'=>'Air Transport International',
    'ASAP MOU Holder FAA Designator'=>'IXXA'
  }

  RISK_MATRIX = {
    # :likelihood       => ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
    # :severity         => (0..4).to_a.reverse,
    :risk_factor      => {"LOW" => "limegreen", "MINOR" => "steelblue", "MEDIUM" => "yellow", "SERIOUS" => "orange", "HIGH" => "red"},
  }

  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Initial Risk',
      mitigate_btn: 'Residual Risk',
      'Baseline' => 'Initial',
      'Mitigate' => 'Residual'
    },

    severity_table: {
      title: 'SEVERITY EXERCISE',

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
      cell_style: 'bold',

      # maps severity / likelihood attribute to position on table
      severity_pos: 'column',
      likelihood_pos: 'row',

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
      limegreen:        { rating: 'Low',       cells: '3/5, 4/4, 4/5',       description: 'Review by appropriate authority to evaluate if corrective and/or preventive action is required.' },
      steelblue:        { rating: 'Minor',     cells: '2/4, 2/5, 3/3',       description: 'Review by appropriate authority. May require tracking and corrective and/or preventive action.' },
      yellow:           { rating: 'Medium',    cells: '1/5, 2/4, 3/3, 4/2',  description: 'Review by appropriate authority, requires tracking and probable corrective and/or preventive action.' },
      orange:           { rating: 'Serious',   cells: '1/4, 2/3, 3/2',       description: 'Unacceptable, requires investigation, resources and corrective and/or preventive action.' },
      red:              { rating: 'High',      cells: '1/2, 1/3, 2/2',       description: 'Unacceptable, requires the highest priority for investigation, resources and corrective and/or preventive action.' }
    },

    risk_table_index: {
      'Low - 5' => 'limegreen',
      'Minor - 4' => 'steelblue',
      'Medium - 3' => 'yellow',
      'Serious - 2' => 'orange',
      'High - 1' => 'red',
      'LOW' => 'limegreen',
      'MINOR' => 'steelblue',
      'MEDIUM' => 'yellow',
      'SERIOUS' => 'orange',
      'HIGH' => 'red',
      'Low' => 'limegreen',
      'Minor' => 'steelblue',
      'Medium' => 'yellow',
      'Serious' => 'orange',
      'High' => 'red',
    },

    risk_table_dict: {
      "red" => "High - 1",
      "orange" => "Serious - 2",
      "yellow" => "Medium - 3",
      "steelblue" => "Minor - 4",
      'limegreen' => 'Low - 5',
    }
  }


end
