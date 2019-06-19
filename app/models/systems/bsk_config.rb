class BSK_Config

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  def self.airline_config
    {
      :version                                        => "1.0.3",

      :name                                           => 'Miami Air International',
      :code                                           => "BSK",
      :base_risk_matrix                               => true,
      :event_summary                                  => false,
      :event_tabulation                               => false,
      :enable_configurable_risk_matrices              => false,
      :allow_set_alert                                => false,
      :has_verification                               => false,
      :has_mobile_app                                 => false,
      :enable_mailer                                  => true,
      :time_zone                                      => 'Eastern Time (US & Canada)',


      # Safety Reporting Module
      :submission_description                         => true,
      :submission_time_zone                           => true,
      :enable_orm                                     => false,
      :observation_phases_trend                       => true,
      :allow_template_nested_fields                   => false,
      :checklist_version                              => '1',

      # Safety Assurance Module
      :allow_reopen_report                            => true,
      :has_root_causes                                => true,
      :enable_recurrence                              => true,


      # SMS IM Module
      :has_framework                                  => true,
    }
  end

  def self.get_sra_meta_fields
    [
      { field: "get_id",                    title: "ID",                                       num_cols: 6,   type: "text",        visible: 'index,show',        required: false},
      { field: "status",                    title: "Status",                                   num_cols: 6,   type: "text",        visible: 'index,show',        required: false},
      { field: 'get_source',                title: 'Source of Input',                           num_cols: 6,   type: 'text',         visible: 'index,show',      required: false},
      {                                                                                                       type: "newline",     visible: 'form,show'},
      { field: "title",                     title: "SRA Title",                                num_cols: 6,   type: "text",        visible: 'index,form,show',   required: false},
      { field: "type_of_change",            title: "Type of Change",                           num_cols: 6,   type: "datalist",    visible: 'index,form,show',   required: false, options: Sra.get_custom_options('SRA Type of Change')},
      { field: "system_task",               title: "System/Task",                              num_cols: 6,   type: "datalist",    visible: 'index,form,show',   required: false, options: Sra.get_custom_options('Systems/Tasks')},
      { field: "responsible_user_id",       title: "Responsible User",                         num_cols: 6,   type: "user",        visible: 'index,form,show',  required: false},
      { field: "reviewer_id",               title: "Quality Reviewer",                         num_cols: 6,   type: "user",        visible: 'form,show',         required: false},
      { field: "approver_id",               title: "Final Approver",                           num_cols: 6,   type: "user",        visible: 'form,show',         required: false},
      { field: "scheduled_completion_date", title: "Scheduled Completion Date",                num_cols: 6,   type: "date",        visible: 'index,form,show',   required: false},
      { field: "current_description",       title: "Describe the Current System",              num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      { field: "plan_description",          title: "Notes",                                    num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                     title: "Affected Department",                      num_cols: 12,  type: "panel_start", visible: 'form,show'},
      { field: "departments",               title: "Affected Departments",                     num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options('Departments')},
      { field: "other_department",          title: "Other Affected Departments",               num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "departments_comment",       title: "Affected Departments Comments",            num_cols: 12,  type: "textarea",    visible: 'form,show',        required: false},
      {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      {                                     title: "Affected Programs",                        num_cols: 12,  type: "panel_start", visible: 'form,show'},
      { field: "programs",                  title: "Affected Programs",                        num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options('Programs')},
      { field: "other_program",             title: "Other Affected Programs",                  num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "programs_comment",          title: "Affected Programs Comments",               num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      {                                     title: "Affected Manuals",                         num_cols: 12,  type: "panel_start", visible: 'form,show'},
      { field: "manuals",                   title: "Affected Manuals",                         num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options('Manuals')},
      { field: "other_manual",              title: "Other Affected Manuals",                   num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "manuals_comment",           title: "Affected Manuals Comments",                num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      {                                     title: "Affected System Task Analysis SHEL(L) Models",           num_cols: 12,  type: "panel_start", visible: 'form,show',},
      { field: "compliances",               title: "Affected System Task Analysis SHEL(L) Models",           num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options("System Task Analysis SHEL(L) Models")},
      { field: "other_compliance",          title: "Other Affected System Task Analysis SHEL(L) Models",     num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
      { field: "compliances_comment",       title: "Affected System Task Analysis SHEL(L) Models Comments",  num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
      {                                                                                       num_cols: 12,  type: "panel_end",   visible: 'form,show'},

      { field: "closing_comment",           title: "Responsible User's Closing Comments",      num_cols: 12,  type: "text",        visible: 'show'},
      { field: "reviewer_comment",          title: "Quality Reviewer's Closing Comments",      num_cols: 12,  type: "text",        visible: 'show'},
      { field: "approver_comment",          title: "Final Approver's Closing Comments",        num_cols: 12,  type: "text",        visible: 'show'},
    ]
  end
  OBSERVATION_PHASES = [
    "Observation Phase",
    "Condition",
    "Threat", "Sub Threat",
    "Error", "Sub Error",
    "Human Factor", "Comment"]



  FAA_INFO = { #CORRECT/REVISE
    "CHDO"=>"ACE-FSDO-09",
    "Region"=>"Eatern",
    "ASAP MOU Holder Name"=>"Miami Air International",
    "ASAP MOU Holder FAA Designator"=>"N/A"
  }


  MATRIX_INFO = {
    severity_table: {
      starting_space: true,
      column_header: ['1','2','3','4','5'],
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
      starting_space: true,
      row_header: ['A', 'B', 'C', 'D'],
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
      starting_space: true,
      column_header: ['1','2','3','4','5'],
      row_header: ['A', 'B', 'C', 'D'],
      rows: [
        ["crimson",     "crimson",      "coral",          "yellow",         "mediumseagreen"      ],
        ["crimson",     "coral",        "yellow",         "steelblue",      "mediumseagreen"      ],
        ["coral",       "yellow",       "steelblue",      "mediumseagreen", "mediumseagreen"      ],
        ["yellow",      "steelblue",    "mediumseagreen", "mediumseagreen", "mediumseagreen"      ],
      ]
    },

    risk_table_dict: {
      crimson:        'Red (A/1, A/2, B/1) - High',
      coral:          'Orange (A/3, B/2, C/1) - Serious',
      yellow:         'Yellow (A/4 B/3, D/1) - Moderate',
      steelblue:      'Blue (B/4, C/3, D/2) - Minor',
      mediumseagreen: 'Green (A/5, B/5, C/4, C/5, D/3, D/4, D/5) - Low',
    },

    risk_table_index: {
      crimson:        "High",
      coral:          "Serious",
      yellow:         "Moderate",
      steelblue:      "Minor",
      mediumseagreen: "Low"
    },

    risk_definitions: {
      crimson:          { rating: 'High',      cells: 'A/1, A/2, and B/1',                      description: '' },
      coral:            { rating: 'Serious',   cells: 'A/3, B/2, and C/1',                      description: '' },
      yellow:           { rating: 'Moderate',  cells: 'A/4, B/3, and D/1',                      description: '' },
      steelblue:        { rating: 'Minor',     cells: 'B/4, C/3, and D/2',                      description: '' },
      mediumseagreen:   { rating: 'Low',       cells: 'A/5, B/5, C/4, C/5, D/3, D/4, and D/5',  description: '' }
    }
  }

  #ALL FOLLOWING MAY NEED CORRECTION/REVISION

  # Calculate the severity based on #{BaseConfig.airline[:code]}'s risk matrix
  def self.calculate_severity(list)
    if list.present?
      list.delete("undefined") # remove "undefined" element from javascript
      return list.map(&:to_i).min
    end
  end

  # Calculate the probability based on #{BaseConfig.airline[:code]}'s risk matrix
  def self.calculate_probability(list)
    if list.present?
      list.delete("undefined") # remove "undefined" element from javascript
      return list.map(&:to_i).min
    end
  end

  def self.print_severity(owner, severity_score)
    MATRIX_INFO[:severity_table_dict][severity_score] unless severity_score.nil?
  end

  def self.print_probability(owner, probability_score)
    MATRIX_INFO[:probability_table_dict][probability_score] unless probability_score.nil?
  end

  def self.print_risk(probability_score, severity_score)
    Rails.logger.debug "Probability score: #{probability_score}, Severity score: #{severity_score}"
    if !probability_score.nil? && !severity_score.nil?
      lookup_table = MATRIX_INFO[:risk_table][:rows]
      return MATRIX_INFO[:risk_table_index][lookup_table[probability_score][severity_score].to_sym]
    end
  end

end
