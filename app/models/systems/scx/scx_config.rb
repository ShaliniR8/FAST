class SCXConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Sun Country Airlines',
    time_zone:                          'Central Time (US & Canada)',
    has_pdf_footer:                      true,

    # SYSTEM CONFIGS
    enable_sso:                         true,
    login_option:                       'dual',
    has_mobile_app:                     true,
    add_attachment_in_any_status:       true,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                   false,
    query_processing_in_rake_task:      false,
  })


  FAA_INFO = DefaultConfig::FAA_INFO.merge({ #CORRECT/REVISE
    'CHDO'=>'Minneapolis-St. Paul FSDO, 6020 28th Avenue South, Minneapolis, MN 55450',
    'Region'=>'Great Lakes',
    'ASAP MOU Holder Name'=>'N/A',
    'ASAP MOU Holder FAA Designator'=>'SCNA'
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
      direction: :left,
      size: 'col-xs-8',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      column_header_name: 'SEVERITY',
      column_header: ['1','2','3','4','5'],
      row_header_name: 'CLASS',
      row_header: [
        'Accident or Incident',
        'Employee/Customer Injury',
        'Assets',
        'Operational Events',
        'Airworthiness',
        'Brand',
        'Customer',
        'Environment',
        'Security',
        'Regulatory',
        'System or Process',
        'Audit Finding',
        'OSHA'
      ],
      rows: [
        [ #Accident or Incident
          'Accident with serious injuries or fatalities; or significant damage to aircraft or property',
          'Serious incident with injuries and/or substantial damage to aircraft or property',
          'Incident with minor injury and/or minor aircraft or property damage',
          'incident with less than minor injury and/or less than minor damage',
          'No relevant safety risk'
        ],
        [ #Employee/Customer Injury
          'Fatality or serious injury with total disability/loss of capacity',
          'Immediate admission to hospital as an inpatient and/or partial disability/loss of capacity',
          'Injury requiring ongoing treatment, with no permanent disability/loss of capacity',
          'Minor injury not resulting in an absence',
          'No injury risk'
        ],
        [ #Assets
          'Multiple Aircraft OTS > 24 hours',
          'One aircraft OTS > 24 hours',
          'Aircraft OTS 2 to 24 hours',
          'Aircraft OTS < 2 hours',
          'No Aircraft OTS'
        ],
        [ #Operational Events
          'Loss of aircraft; beyond crew capability, operating with no meaningful safety margins',
          'Physical distress/high workload impairing the accuracy and completion of tasks',
          'Large reduction in safety margins; reduction in ability of crew to cope with adverse operating conditions',
          'Operation beyond operating limitations; Use of abnormal procedures',
          'No effect on operational safety'
        ],
        [ #Airworthiness
          'Returning an aircraft to service and operating it in a non-standard, unairworthy, or unsafe condition',
          'Returning an aircraft to service and operating it in a non-standard but not unsafe condition',
          'Returning an aircraft to service in a non-standard condition, but not operating it',
          'Affecting aircraft or systems reliability above established control limits but no affect on airworthiness or the safe operation of the aircraft',
          'No effect on airworthiness'
        ],
        [ #Brand
          'Extended negative national media coverage resulting in a substantial change in public opinion of Sun Country',
          'Short term negative media/internet activity resulting in minor change in public opinion of Sun Country',
          'Short term negative media/internet activity resulting in no change in public opinion of Sun Country',
          'Isolated negative media/internet activity resulting in no change in public opinion of Sun Country',
          'No negative media/internet activity',
        ],
        [ #Customer
          "<b><center>Extreme Customer Dissatisfaction</b></center>More than 500 customers affected for 48 hours or more",
          "<b><center>Customer Dissatisfaction</b></center>More than 500 customers affected for 3 to 48 hours",
          "<b><center>Customer Annoyance</b></center>Less than 500 customers affected for 3 to 48 hours",
          "<b><center>Isolated Customer Annoyance</b></center>Less than 500 customers affected for up to 3 hours",
          'No customer disruptions'
        ],
        [ #Environment
          "Severe Danger to Environment:<br />Large, significant waste of resources and emissions into water, air, or soil",
          'Medium significance in waste of resources and emissions into water, air, or soil',
          'Small significance in waste of resources and emissions into water, air, or soil',
          'Small waste or emission, no relevant risk of pollution',
          'No relevant risk of pollution, no spill but an undesirable situation'
        ],
        [ #Security
          'Loss of aircraft or death of Sun Country employee due to successful attack, terrorist activity, or civil unrest',
          'Security threat is genuine. Situation can only be resolved by handing control to outside agencies',
          'Security threat is genuine. Situation is only mitigated/resolved with assistance of outside agencies',
          'Security threat is genuine but can be mitigated or resolved by Sun Country',
          'Security threat is a hoax'
        ],
        [ #Regulatory
          "<center><b>Major Regulatory Deviation</b></center>Loss of company approvals, permits or certificates, resulting in the suspension of all operations",
          "<center><b>Moderate Regulatory Deviation</b></center>Loss of company approvals, permits or certificates, resulting in suspension in part of Sun Country operations",
          "<center><b>Minor Regulatory Deviation</b></center>Major breach of company policy or SOPs with no direct impact on approvals, permits or certificates, with a significant negative effect of ability to manage operations. Attitude of regulatory authority towards Sun Country has been negatively impacted",
          "<center><b>Policy/Procedure Deviation</b></center>Breach of company policy or SOPs, with no direct impact on approvals, certificates, permits, with a minor effect of ability to manage operations. Falls below industry \"best practices\"",
          "No breach of company requirements; No impact on approvals or permits"
        ],
        [ #System or Process
          'Loss or breakdown of entire system, subsystem or process',
          'Partial breakdown of a system, subsystem, or process',
          'System deficiencies leading to poor reliability or disruption',
          'Little to no effect on system, subsystem, or process',
          'No impact on system, subsystem, or process'
        ],
        [ #Audit Finding
          'Safety of Operations in Doubt',
          'Non-Compliance with company policy or CFR',
          'Non-conformance with company policy or CFR',
          'Audit Observation',
          'No findings or observations'
        ],
        [ #OSHA
          'Willful',
          'Repeat',
          'Serious',
          'General/Other',
          'No breach of OSHA requirements'
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
      row_header: ['A', 'B', 'C', 'D'],
      column_header_name: 'CRITERIA',
      column_header: ['Reactive Assessment (Control Effectiveness)', 'Proactive Assessment (Likelihood)'],
      rows: [
        [ #A
          "<center><b>Not Effective</b></center>Remaining controls were ineffective or no controls remained. The only thing preventing an accident were luck or exceptional skill, which is not trained or required",
          "<center><b>Likely to Occur</b></center>(Will occur in most circumstances, not surprised if it happens) or occurs > 1 in 100"
        ],
        [ #B
          "<center><b>Minimal</b></center>Some controls were left but their total effectiveness was minimal",
          "<center><b>Possible to Occur</b></center>(Might occur in some circumstances) or occurs > 1 in 1,000"
        ],
        [ #C
          "<center><b>Limited</b></center>An abnormal situation, more demanding to manage, but with still a considerable remaining safety margin",
          "<center><b>Unlikely to Occur</b></center>(Could occur in some circumstances, surprised if it happens) or occurs in > 1 in 10,000"
        ],
        [ #D
          "<center><b>Effective</b></center>Consisting of several good controls",
          "<center><b>Rare to Occur</b></center>(May occur but only in exceptional circumstances, may happen but it would only be highly unexpected) or occurs > 1 in 1,000,000"
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
      column_header: ['1','2','3','4','5'],
      row_header_name: 'PROBABILITY',
      row_header: ['A', 'B', 'C', 'D'],

      rows_color: [
        ["crimson",     "crimson",      "coral",          "yellow",         "mediumseagreen"      ],
        ["crimson",     "coral",        "yellow",         "steelblue",      "mediumseagreen"      ],
        ["coral",       "yellow",       "steelblue",      "mediumseagreen", "mediumseagreen"      ],
        ["yellow",      "steelblue",    "mediumseagreen", "mediumseagreen", "mediumseagreen"      ],
      ],
    },

    risk_table_index: {
      "High" => 'crimson',
      "Serious" => 'coral',
      "Moderate" => 'yellow',
      "Minor" => 'steelblue',
      "Low" => 'mediumseagreen'
    },

    risk_table_dict: {
      crimson:        "High",
      coral:          "Serious",
      yellow:         "Moderate",
      steelblue:      "Minor",
      mediumseagreen: "Low",
    },

    risk_definitions: {
      crimson:          { rating: 'High',      cells: 'A/1, A/2, and B/1',                      description: '' },
      coral:            { rating: 'Serious',   cells: 'A/3, B/2, and C/1',                      description: '' },
      yellow:           { rating: 'Moderate',  cells: 'A/4, B/3, and D/1',                      description: '' },
      steelblue:        { rating: 'Minor',     cells: 'B/4, C/3, and D/2',                      description: '' },
      mediumseagreen:   { rating: 'Low',       cells: 'A/5, B/5, C/4, C/5, D/3, D/4, and D/5',  description: '' }
    },
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
