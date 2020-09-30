class WAAConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'World Atlantic Airlines',
    time_zone:                          'Central Time (US & Canada)',

    # SYSTEM CONFIGS

    # SYSTEM-WIDE FORM CONFIGS
    has_root_causes:                    false,

  })

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
      row_header: ['I', 'II', 'III', 'IV'],
      column_header_name: 'CLASS',
      column_header: ['Consequence', 'OR', 'OR', 'OR', 'OR', 'OR', 'OR'],
      rows: [
        [
          'Accident with serious injuries or fatalities, or significant damageto aircraft',
          'Death, total disability of an employee or passenger',
          'Operating and aircraft in an unairworthy and unsafe condition',
          'Loss or breakdown of entire system or sub-systems',
          'Regulatory Deviation',
          'Catastrophic',
          'Attempted or actual breach of the flight deck'
        ],
        [
          'Accident/Serious incident with injuries and/or moderate damage to aircraft',
          'Partial disability, temporary disability >3 mo. of an employee or passenger',
          'Operating an aircraft in an unairworthy but not unsafe condition',
          'Partial breakdown of a system or sub-system',
          'Regulatory Deviation',
          'Critical',
          'Life threatening behavior'
        ],
        [
          'Accident/incident with minor injury and or minor aircraft damage',
          'Lost workday injury of an employee',
          'Returning an aircraft to service in an unairworthy condition, not operated',
          'Systems deficiencies leading to poor dependability to the schedules',
          'Regulatory Deviation',
          'Marginal',
          'Physically abusive behavior'
        ],
        [
          'Less than minor injury and/or less than minor system damage',
          'Any injury employee or passenger',
          'Affecting aircraft or systems reliability above established control limits but no effect on airworthiness or safety of operation of an aircraft',
          'Little or no effect on systems or sub-system, or for general informational purposes only',
          'Policy and/ or Procedure Deviation',
          'Remote',
          'Disruptive /verbally abusive behaviorsuspicious or threatening'
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

      orientation: :horizontal,
      direction: :right,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: '',
      row_header: ['Frequent', 'Probable', 'Occasional', 'Remote'],
      column_header_name: 'PROBABILITY',
      column_header: [''],
      rows: [
        [
          'Likely to occur within 7 Days',
        ],
        [
          'Likely to occur within 30 Days',
        ],
        [
          'Likely to occur within 90 Days',
        ],
        [
          'Likely to occur outside of 90 Days'
        ],
      ]
    },

    probability_table_dict: {
      0 => 'Likely to occur within 7 Days',
      1 => 'Likely to occur within 30 Days',
      2 => 'Likely to occur within 90 Days',
      3 => 'Likely to occur outside of 90 Days'
    },

    risk_table: {
      title: 'RISK ASSESSMENT MATRIX',

      size: 'col-xs-6',
      title_style: 'matrixTitle',
      main_header_style: 'matrixMainHeader',
      header_style: 'matrixHeader',
      cell_name: 'risk_td',

      row_header_name: 'PROBABILITY',
      row_header: ['Frequent', 'Probable', 'Occasional', 'Remote'],
      column_header_name: 'SEVERITY',
      column_header: ['I', 'II', 'III', 'IV'],
      rows_color: [
        ["crimson",     "crimson",        "crimson",        "yellow"        ],
        ["crimson",     "crimson",        "yellow",         "mediumseagreen"],
        ["crimson",     "yellow",         "mediumseagreen", "mediumseagreen"],
        ["yellow",      "mediumseagreen", "mediumseagreen", "mediumseagreen"],
      ],
    },

    risk_definitions: {
      #   '#60FF60' => {rating: 'Green - Acceptable',      cells: "A1, B2, C3, D4", description: "Acceptable", description_approval: 'here'                },
      #   yellow:      {rating: 'Yellow - Acceptable with mitigation', cells: "A2, B2, C4",     description: "Acceptable with Mitigation", description_approval: 'here'   },
      #   orange:      {rating: 'Orange - Unacceptable',     cells: "A4, A3, B4",     description: "Unacceptable", description_approval: 'here'                 },
      red: {
        rating: 'Accountable Executive',
        cells: "A1, A2, A3, B1, B2, C1",
        description: "High - (Red) Imminent and Unacceptable Danger requiring the highest priority of investigations, resources and corrective action. Requires tracking and review by appropriate authority. (Department Heads in Conjunction with DOS).",
      },
      yellow: {
        rating: 'Top Management',
        cells: "A4, B3, C2, D1",
        description: "Medium - (Yellow) - May be acceptable with review by appropriate authority (Department VP in conjunction with DOS), requires tracking and possible action. There may be acceptable policies and procedures in place",
      },
      '#60FF60' => {
        rating: 'Managers & Supervisors',
        cells: "B4, C3, C4, D2, D3, D4",
        description: "Low - (Green) - Requires tracking and possible action. There may be acceptable policies and procedures in place; and it may be acceptable without further action.",
      },
    },

    risk_table_index: {
      "High"      => 'crimson',
      "Moderate"  => 'yellow',
      "Low"       => 'mediumseagreen'
    },
  }

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    "CHDO" => "FAA Flight Standards District Office, 300W 36th Ave, Suite 101, Anchorage, AK, 99503",
    "Region" => "Anchorage",
    "ASAP MOU Holder Name" => "N/A",
    "ASAP MOU Holder FAA Designator" => "N/A"
  })


end
