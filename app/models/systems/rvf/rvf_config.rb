class RVFConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Ravn Alaska',
    time_zone:                          'Alaska',

    # SYSTEM CONFIGS
    # enable_sso:                         true,
    # login_option:                       'sso',
    has_mobile_app:                     true,
    cisp_integration:                   true,

    # SYSTEM-WIDE FORM CONFIGS
    base_risk_matrix:                  false,
    allow_reopen_forms:                false,
    has_root_causes:                   false,
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


  P_CODE = 'FFT671'
  CISP_TITLE_PARSE = DefaultConfig::CISP_TITLE_PARSE.deep_merge({})
  CISP_FIELD_PARSE = DefaultConfig::CISP_FIELD_PARSE.deep_merge({})

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
      title: 'SEVERTIY EXERCISE',
      orientation: :horizontal,
      direction: :left,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'CLASS',
      row_header: [
        'Accident or Incident',
        'Employee or Customer Injury',
        'Corporate Image / Brand',
        'Operational Events',
        'Systems or Processes',
        'Regulatory Deviation / Financial',
        'OSHA',
        'Airworthiness',
        'Audit Finding'
      ],
      column_header_name: 'SEVERITY',
      column_header: ['I','II','III','IV','V'],
      rows: [
        [ #Accident or Incident
          'Accident with serious damage to aircraft and/or property',
          'Serious incident with substantial damage to aircraft or property',
          'Incident with minor aircraft or property damage',
          'Incident with less than minor system or property damage',
          'No damage</br>(Informational Report)'
        ],
        [ #Employee/Customer Injury
          'Fatality or serious injury with total disability/loss of capacity',
          'Immediate admission to hospital as an inpatient and/or partial disability/loss of capacity',
          'Injury requiring ongoing treatment with no permanent disability/loss of capacity',
          ' Minor injury with or with out first aid treatment; no follow-up required',
          'No injury or no treatment required</br>(Informational Report)'
        ],
        [ #Corporate Image / Brand
          'Potential for Corporate failure, permanent impact on business system wide',
          'Adverse effect on corporate image, significant impact on a region',
          'Major effect on corporate image, isolated to a single location',
          'Minor effect on Corporate image, isolated effect that is easily reversible',
          'Negligible effect on corporate image, little to no potential for negative impact on the brand</br>(Informational Report)',
        ],
        [ #Operational Events
          'State of emergency for an operational condition impacting the immediate safe operation of an aircraft (e.g. declared emergency, immediate air interrupt, high speed abort)',
          'Condition resulting in abnormal procedures impacting the continued safe operation of an aircraft (e.g. special handling without declared emergency, en route diversion, low speed abort)',
          'Condition resulting in abnormal procedures with potential to impact safe operation of an aircraft (e.g. battery charger failure, single source of electrical power)',
          'Condition resulting in normal procedures with potential to impact safe operation of an aircraft (e.g false indications)',
          'No equipment damage, returned to service same day or next day, no reduction in safety margins</br>(Informational Report)'
        ],
        [ #Systems or Processes
          'Loss or breakdown of entire system, subsystem, or process',
          'Partial breakdown of a subsystem, or process',
          'System deficiencies leading to poor dependability or disruption',
          'Little or no effect on system, subsystem, or process',
          'No measurable effect; continue monitoring</br>(Informational Report)'
        ],
        [ #Regulatory Deviation / Financial
          'Major Regulatory </br>Deviation</br>&gt;$1M',
          'Moderate Regulatory </br>Deviation</br>&gt;$250K',
          'Minor Regulatory </br>Deviation</br>&gt;$50K',
          'Company Policy and/or Procedure Deviation</br>&lt;$50K</center',
          'No deviation; continue monitoring</br>(Informational Report)'
        ],
        [ #OSHA
          'Willful',
          'Repeat',
          'Serious',
          'General/Other',
          'No deviation; continue monitoring</br>(Informational Report)'
        ],
        [ #Airworthiness
          'Returning an aircraft to service and operating it in a nonstandard, unairworthy, or unsafe condition',
          'Returning an aircraft to service and operating it in a nonstandard or unairworthy, but not unsafe condition',
          'Returning an aircraft to service in a nonstandard, unairworthy, or unsafe condition, not operated',
          'Affecting aircraft or systems reliability above established control limits but no effect on airworthiness or safety of operation of an aircraft',
          'No safety implication</br>(Informational Report)'
        ],
        [ #Audit Finding
          'Willful violation of any safety regulation that could result in serious injury or death',
          'A noncompliance finding resulting in major system, process, or operational degradation',
          'Nonconformance to Company policy and procedures',
          'Finding presents limited opportunities for improvement',
          'Finding presents little to no risk to organization'
        ],
      ]
    },

    severity_table_dict: {
      0 => 'I',
      1 => 'II',
      2 => 'III',
      3 => 'IV',
      4 => 'V'
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
      row_header: ['A - Frequent (Not Effective)', 'B - Likely (Not Effective)', 'C - Repeatable (Minimal Effectiveness)', 'D - Isolated (Limited Effectiveness)', 'E - Improbable (Effective)'],
      column_header_name: 'CRITERIA',
      column_header: ['Reactive Assessment (Control Effectiveness) Audit Findings', 'Reactive Assessment (Control Effectiveness) Known Occurrences', 'Proactive Assessment (Likelihood)'],

      rows: [
        [ #A
          'Multiple findings during audit and/or found on previous audit',
          'Multiple continuous occurrences across system and/or subsystem',
          '<b>Definitiely will occur</b> (i.e., will occur in most circumstances, not surprised if it happens, etc.).</br>Occurs ≥ 1 in 100; 80 to 100 percent chance of occurrence.'
        ],
        [ #B
          'Finding on this audit and/or previous audit',
          'Several occurrences across system or subsystemt',
          '<b>Likely to occur</b> (i.e., will occur in some circumstances, etc.).</br>Occurs 1 in 100 to 1,000; 60 to 80 percent chance of occurrence.'
        ],
        [ #C
          'Multiple findings during audit',
          ' Repeatable occurrences across system or subsystem',
          '<b>Occasionally will occur</b> (i.e., might occur in some circumstances, surprised if it happens, etc.).</br>Occurs 1 in 1,000 to 10,000; 40 to 60 percent chance of occurrence.'
        ],
        [ #D
          'Single finding during audit',
          'Uncommon occurrence across system; however has occurred before',
          '<b>Seldom to occur</b> (i.e., may occur but only in exceptional circumstances, may happen but it would be highly unexpected, etc.).</br>Occurs 1 in 10,000 to 1,000,000; 20 to 40 percent chance of occurrence.'
        ],
        [ #E
          'No Audit Findings',
          'First occurrence within the operation',
          '<b>Unlikely to occur.</b></br>Less than 20 percent chance of occurrence.'
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D',
      4 => 'E'
    },

    risk_table: {
      title: 'RISK ASSESSMENT MATRIX',

      size: 'col-xs-6',
      title_style: 'matrixTitle',
      main_header_style: 'matrixMainHeader',
      header_style: 'matrixHeader',
      cell_name: 'risk_td',
      row_header_name: 'PROBABILITY',
      row_header: ['A', 'B', 'C', 'D', 'E'],
      column_header_name: 'SEVERITY',
      column_header: ['I','II','III','IV','V'],
      rows_color: [
        ["crimson",     "crimson",      "coral",          "coral",          "yellow"         ],
        ["crimson",     "coral",        "coral",          "yellow",         "steelblue"      ],
        ["coral",       "coral",        "yellow",         "yellow",         "steelblue"      ],
        ["coral",       "yellow",       "yellow",         "steelblue",      "mediumseagreen" ],
        ["yellow",      "steelblue",    "steelblue",      "mediumseagreen", "mediumseagreen" ],
      ],
      rows_content: [
        ['High',        'High',       'Serious',      'Serious',    'Moderate'],
        ['High',        'Serious',    'Serious',      'Moderate',   'Minor'   ],
        ['Serious',     'Serious',    'Moderate',     'Moderate',   'Minor'   ],
        ['Serious',     'Moderate',   'Moderate',     'Minor',      'Low'     ],
        ['Moderate',    'Minor',      'Minor',        'Low',        'Low'     ]
      ]
    },

    risk_definitions: {

      # limegreen:        { rating: 'LOW',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   description: 'No action may be required, but risk reviewed for possible control/mitigation to ALARP',    description_approval: 'Manager or higher review and acceptance required*'                                                            },
      # steelblue:        { rating: 'MINOR',     cells: '2/4, 2/5, 3/3, 4/2, 5/2',                  description: 'Review and control/mitigate risk to ALARP',                                                description_approval: 'Senior/Regional or Program Manager or higher review and acceptance required*'                                 },
      # yellow:           { rating: 'MODERATE',    cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',             description: 'Mitigate risk to ALARP, acceptable with implementation of risk controls',                  description_approval: 'Director or higher review and acceptance required*'                                                           },
      # orange:           { rating: 'SERIOUS',   cells: '3/6, 4/5, 5/4',                            description: 'Operations may be continued, mitigation of risk to ALARP',                                 description_approval: 'Part 119 or Officer acceptance required with review and approval of Integrated Safety Committee*'             },
      # red:              { rating: 'HIGH',      cells: '4/6, 5/5, 5/6',                            description: 'Mitigation required, risk cannot be accepted',                                             description_approval: 'Review by Part 119 to determine if operations be discontinued until risk is mitigated to an acceptable level' }

      limegreen:        { rating: 'Low',       cells: '1/2, 1/3, 1/4, 1/5, 1/5, 2/2, 2/3, 3/2',   },
      steelblue:        { rating: 'Minor',     cells: '2/4, 2/5, 3/3, 4/2, 5/2',                  },
      yellow:           { rating: 'Moderate',    cells: '2/6, 3/4, 3/5, 4/3, 4/4, 5/3',             },
      orange:           { rating: 'Serious',   cells: '3/6, 4/5, 5/4',                            },
      red:              { rating: 'High',      cells: '4/6, 5/5, 5/6',                            }

    },

    risk_table_index: {
      'LOW' => 'mediumseagreen',
      'MINOR' => 'steelblue',
      'MODERATE' => 'yellow',
      'SERIOUS' => 'coral',
      'HIGH' => 'crimson',
      'Low' => 'mediumseagreen',
      'Minor' => 'steelblue',
      'Moderate' => 'yellow',
      'Serious' => 'coral',
      'High' => 'crimson',
    },

    risk_table_dict: {
      'mediumseagreen' => 'Low',
      'steelblue' => 'Minor',
      'yellow' => 'Moderate',
      'coral' => 'Serious',
      'crimson' => 'High',
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
