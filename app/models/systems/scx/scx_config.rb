class SCXConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

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
    attachment_identified_view_access:  false,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                   false,
    global_admin_default:               false,
    advanced_checklist_data_type:       true,
    checklist_query:                    true,
  })

  LAUNCH_OBJECTS = DefaultConfig::LAUNCH_OBJECTS.merge({
    sras: ['Sra']
  })

  LINK_OBJECTS = DefaultConfig::LINK_OBJECTS.merge({
    sras: ['Sra']
  })

  INSTRUCTIONS = {
    'Hazard' => {
      simplified_form_fields: [
        '<p class="field_name">Hazard Description:</p> A hazard can also be understood as a Hazardous Condition. What is currently in the system/program/process that might contribute to an unsafe condition or elevated risk to employees or company?'
      ],
      fields: [
        '<p class="field_name">Description:</p> A hazard can also be understood as a Hazardous Condition. What is currently in the system/program/process that might contribute to an unsafe condition or elevated risk to employees or company?'
      ],
      notes: [
        'Remember to add a root cause if this is a reactive hazard (if this hazard has actually occurred).'
      ]
    },
    'RiskControl' => {
      simplified_form_fields: [
        '<p class="field_name">Risk Control Description:</p> A Risk Control is an action to remove or lessen the cause or effects of a detected nonconformity or other undesirable situation. If this risk control is implemented, are other processes going to be adversely affected? Be sure this corrective action does not introduce a substitute, additional, or transferred risk elsewhere.',
        '<p class="field_name">Risk Control Scheduled Completion Date:</p> The date this risk control is due to be identified, documented and approved by the responsible user and final approver. (Plan not implementation)'
      ],
      fields: [
        '<p class="field_name">Date for Follow-Up/Monitor Plan:</p> The date this risk control is planned to be implemented. (i.e, occur, published, updated, etc.)'
        '<p class="field_name">Description of Risk Control/Mitigation Plan:</p> A Risk Control is an action to remove or lessen the cause or effects of a detected nonconformity or other undesirable situation. If this risk control is implemented, are other processes going to be adversely affected? Be sure this corrective action does not introduce a substitute, additional, or transferred risk elsewhere.',
        '<p class="field_name">Scheduled Completion Date:</p> The date this risk control is due to be identified, documented and approved by the responsible user and final approver. (Plan not implementation)',
      ]
    }
  }

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
        'System/  Program/ Policy',
        'Operations',
        'Security',
        'Injury'
      ],
      rows: [
        [ #System/  Program/ Policy
          'Loss or breakdown of entire system, subsystem, program or policy conformity. ',
          'Major breakdown of a system, subsystem, program or policy conformity.',
          'Partial breakdown of a system, subsystem, program, or policy conformity. ',
          'Little to no effect on system, subsystem, program or policy compliance. But falls below industry best practices.',
          'No impact on system, subsystem, program, or breach of policy.'
        ],
        [ #Operations
          'Control loss aircraft or equipment; beyond employee capability, operating with no meaningful safety margins.',
          'Physical distress/high workload impairing the accuracy and completion of tasks. Equipment/aircraft difficult to control.',
          'Large reduction in safety margins; reduction in ability to cope with adverse operating conditions or equipment.',
          'Operation beyond operating limitations; Use of abnormal procedures or equipment, or unfamiliar employees.',
          'No effect on operational safety.'
        ],
        [ #Security
          'Loss of aircraft or death of employee due to successful attack, terrorist activity, or civil unrest.',
          'Threat is genuine.  Situation can only be resolved by handing control to outside agencies.',
          'Threat is genuine. Situation is only mitigated/resolved with assistance of outside agencies.',
          'Security threat is genuine but can be mitigated or resolved by employees/company.',
          'Security threat is a hoax or misidentified.'
        ],
        [ #Injury
          'Fatality or serious injury with total disability/loss of capacity.',
          'Immediate admission to hospital as an inpatient and/or partial disability/loss of capacity.',
          'Injury requiring ongoing treatment, with no permanent disability/loss of capacity.',
          'Minor injury not resulting in an absence.',
          'No injury risk.'
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
      column_header: [''],
      rows: [
        [ #A
          "<center><b>Likely to Occur</b></center>Will occur in most circumstances, not surprised if it happens (1 in 100 events)"
        ],
        [ #B
          "<center><b>Possible to Occur</b></center>Might occur in some circumstances (1 in 1000 events)"
        ],
        [ #C
          "<center><b>Unlikely to Occur</b></center>Could occur in some circumstances, surprised if it happens (1 in 5000 events)"
        ],
        [ #D
          "<center><b>Rare to Occur</b></center>(May occur but only in exceptional circumstances, may happen but would only be highly unexpected (1 in 10,000 events)"
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
    sso_identifier_tag: 'email_address',
    sso_identifier_attribute: 'email',

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
