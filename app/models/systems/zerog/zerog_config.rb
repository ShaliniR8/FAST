class ZEROGConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = ['ASAP', 'SMS']


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'ZERO G',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:               true,
    asrs_integration:             false,


    # Customizable features
    sms_im_visibility:            false,
    safety_promotion_visibility:  true,
    drop_down_risk_selection:     false,
    base_risk_matrix:             false,

    # TO BE REMOVED
    base_risk_matrix:             false,
    has_verification:             true,
    hazard_root_cause_lock:       true

  })

    # SMS IM Module

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
      direction: :up,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      column_header_name: 'RATING',
      column_header: ['I','II', 'III', 'IV'],
      row_header_name: 'SEVERITY LEVELS',
      row_header: ['Accident or Incident','Injury','Airworthiness','Systems Operations','Security', 'Damage To Assets', 'Compliance/Audit', 'Operation', 'General'],
      rows: [
        ["Accident with serious injuries or fatalities, or significant damage to aircraft", "Accident / Serious incident with injuries and/or moderate damage to aircraft", "Accident/Incident with minor injury and/or minor aircraft damage", "Less than minor injury and/or less than minor damage"], 
        ["Death, total disability of an employee or passenger", "Partial disability, temporary disability > 3 mo. of an employee or passenger", "Lost workday injury of an employee", "Any injury to employee or passenger"], 
        ["Operating an aircraft in an unairworthy and unsafe condition", "Operating an aircraft in an unairworthy but not unsafe condition", "Returning an aircraft to service in an unairworthy condition, not operated", "Affecting aircraft or systems reliability above established control limits but no effect on airworthiness or safety of operation"], 
        ["Loss or breakdown of entire system or syb-systems", "Partial breakdown of a system or sub-system", "System deficiencies leading to poor dependability or disruption to the schedules", "Little or no effect on system or sub-system, or for general informational purpose only"], 
        ["Attempted or actual breach of the flight deck", "Life threatening behaviour", "Physically abusive behaviour", "Disruptive/verbally abusive behaviour"], 
        ["Catastrophic damage > US $1M", "Major damage < US $1M", "Substantial damage < US $250K", "Minor Damage <US 50K"], 
        ["Non-Compliance with major impact on safety of operations, item warrants immediate attention and remedy", "Non-Compliance with minor impact on safety of operations. No immediate adverse consequence currently exists.", "Non-Conformance with negligible safety implication", "Observation/Non-Conformance with recommended best practice. No safety implication."], 
        ["Aircraft Structural integrity or Safety of Crew/Passengers directly at Risk", "Aircraft structural integrity and life of crew and passenger indirectly at risk", "Operation beyond operating limitations; Use of abnormal procedures", "Policy or procedure deviation with limited safety implication"], 
        ["Catastrophic loss of aircraft or life Any NTSB Reportable Event", "SRC Investigation required, FAA or Foreign Regulatory Investigation", "Voluntary Disclosure required", "Informational Only"]
      ],
    },

    severity_table_dict: {
      0 => '0',
      1 => '1',
      2 => '2',
      3 => '3',
      4 => '4',
    },

    probability_table: {
      title: 'Likelihood Levels/ Probability of Occurences',
      orientation: :vertical,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',
      column_header: ['REACTIVE Assessment (Control Effectiveness)', 'PROACTIVE Assessment (Likelihood)'],
      column_header_name: 'Qualitative Definition',
      row_header: ['A' , 'B', 'C', 'D'  ],
      row_header_name: 'Meaning',

      rows: [
        [ 
          "<b> NOT EFFECTIVE </b> <br/> Remaining controls were ineffective or No controls remained.", 
          "<b> LIKELY </b> <br/> to occur ( Will occur in most circumstances, not surprised if it happens) or Occurs <span>&#8805;</span> 1 in 100."
        ], 
        [
          "<b> MINIMAL </b> <br/> Some controls left but their total effectiveness were minimal.", 
          "<b> POSSIBLE </b> <br/> to occur (might occur in some circumstances) or Occurs 1 in 100 to 1,000."
        ], 
        [
          "<b> LIMITED </b> <br/> Abnormal situation more demanding to manage. Still a considerate remaining margin.", 
          "<b> UNLIKELY </b> <br/> to occur (Could occur in some circumstances, surprised if it happens) or Occurs 1 in 1,000 to 10,000."
        ],
        [
          "<b> EFFECTIVE </b> <br/> Consisting of several good controls.", 
          "<b> RARE </b> <br/> to occur (May occur in exceptional circumstances, would be highly unexpected) or Occurs 1 in 10,000 to 1,000,000."
        ]
      ], #End of rows
    },

    probability_table_dict: {
      0 => '(A) Improbable',
      1 => '(B) Seldom',
      2 => '(C) Occasional',
      3 => '(D) Probable',
      4 => '(E) Frequent',
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

      column_header_name: 'RATING',
      column_header: ['I', 'II', 'III', 'IV'],
      row_header_name: 'PROBABILITY',
      row_header: [
        'A',
        'B',
        'C',
        'D'],
      rows_color: [
        ['red',       'red',    'orange',     'yellow'],
        ['red',       'orange',  'yellow',    '#0096FF'],
        ['orange',    'yellow',  '#0096FF',  'limegreen'],
        ['yellow',    '#0096FF','limegreen', 'limegreen']
      ],
    },

    risk_table_index: {
      "LOW RISK" => 'limegreen',
      "MEDIUM RISK" => 'yellow',
      "HIGH RISK" => 'red',
    },

    risk_table_dict: {
      limegreen:    'LOW RISK',
      yellow:       'MEDIUM RISK',
      red:          'HIGH RISK' ,
    },

    risk_definitions: {
      limegreen:    { rating: 'NEGLIGIBLE', description: 'Requires tracking (REQUIRED ACTION) <hr class="defn_hr"/> Acceptable at all levels (RISK ACCEPTANCE AUTHORITY)'},
      '#0096FF' =>    { rating: 'MINOR', description: 'Requires tracking and possible action. There are acceptable policies and procedures in place. (REQUIRED ACTION) <hr class="defn_hr"/> Requires review and approval by Departmental Manager (RISK ACCEPTANCE AUTHORITY)' },
      yellow:       { rating: 'MODERATE', description: 'Requires review and approval by Departmental Manager in conjunction with the Safety Department (REQUIRED ACTION) <hr class="defn_hr"/> Requires tracking, review, and approval by Departmental Director in conjunction with the Director of Safety.(RISK ACCEPTANCE AUTHORITY)' },
      orange:       { rating: 'HIGH', description: 'Imminent Danger, unacceptable, and/or requires the highest priority for investigation, resources and corrective action. (REQUIRED ACTION) <hr class="defn_hr"/> Requires tracking review, and approval by Accountable Executive in conjunction with the VP Safety and Regulatory Compliance (RISK ACCEPTANCE AUTHORITY)' },
      red:          { rating: 'SEVERE', description: 'Imminent Danger, unacceptable, and/or requires the highest priority for investigation, resources and corrective action. (REQUIRED ACTION) <hr class="defn_hr"/> Requires tracking, review, and approval by Accountable Executive in conjunction with the VP Safety and Regulatory Compliance (RISK ACCEPTANCE AUTHORITY)' },
    },
  }

end
