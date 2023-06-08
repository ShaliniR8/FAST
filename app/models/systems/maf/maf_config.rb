class MAFConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Mission Aviation Fellowship',
    time_zone:                    'Eastern Time (US & Canada)',


    # SYSTEM CONFIGS
    enable_sso:                         true,
    login_option:                       'dual',
    advanced_checklist_data_type:  true,
    checklist_query:               true,
    has_mobile_app:                true,

    global_admin_default:          false,

    })

  LABELS = DefaultConfig::LABELS.merge({
    incomplete:                   'Draft'
  })

  EMPLOYEE_GROUPS = {
    "West Congo"  => "west-congo",
    "East Congo"  => "east-congo",
    "Lesotho"     => "lesotho",
    "Mozambique"  => "mozambique",
    "Guinea"      => "guinea",
    "Liberia"     => "liberia",
    "Afghanistan" => "afghanistan",
    "Laos"        => "laos",
    "Haiti"       => "haiti",
    "Ecuador"     => "ecuador",
    "Suriname"    => "suriname",
    "Papua"       => "papua",
    "Kalimantan"  => "kalimantan",
    "Nampa"       => "nampa",
  }

  EVENT_TITLE = 'Submission Title'
  EVENT_DATE = 'Date and Time of Occurrence/Observation'

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
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: ' ',
      row_header: [
        'Aviation Occurrence',
        'Aircraft overdue',
        'Aviation Security',
        'Criminal',
        'Financial',
        'Business continuity (environmental/reputation)',
        'Medical/injury',
        'Natural phenomenon within program context',
        'Other events'
      ],
      column_header_name: 'SEVERITY',
      column_header: ['Catastrophic', 'Major', 'Moderate', 'Minor', 'Negligible'],
      rows: [
        [ #'Aviation Occurrence'
          'Accident with death',
          'Accident with serious injury',
          'Accident or serious incident',
          'Incident',
          'Hanger rash or similar occurrence'
        ],
        [ #'Aircraft overdue'
          'Aircraft overdue or no contact for more than 12 hours – distress phase',
          'Aircraft overdue or no contact for more than 4 hours – distress phase',
          'Aircraft overdue or no contact for more than 2 hours - distress phase',
          'Aircraft overdue or no contact for 1 hour – uncertainty phase',
          'Aircraft overdue or no contact for 30 mins – uncertainty phase'
        ],
        [ #'Aviation Security'
          'Terrorist or major security event occurs at a security controlled aerodrome and MAF staff or operation is adversely impacted',
          'Terrorist or major security event occurs at a security controlled aerodrome where MAF is based',
          'Suspected terrorist or criminal surveillance at a security controlled aerodrome where MAF is based',
          'Unauthorised airside access at a security controlled aerodrome due to MAF failing',
          'Passenger refuses aviation screening procedures or screening procedures find contraband items'
        ],
        [ #'Criminal'
          'Violent death, rape – public knowledge, kidnap and hostage',
          'Violent assault, rape – no public knowledge',
          'Assault of personnel, sexual assault other than rape',
          'Greater than normal harassment of personnel. Petty theft, vandalism, property loss',
          'Normal routine  problems for the context'
        ],
        [ #'Financial'
          '$ 1,000,000s',
          '$ 100,000s',
          '$ 10,000s',
          '$ 1,000s',
          '$ 100s'
        ],
        [ #'Business continuity (environmental/reputation)'
          'Loss of operations in a region, widespread permanent environmental or reputation damage',
          'Rapid program evacuation, long term widespread environment or reputation damage',
          'Potential loss of operation in a country, draw down of non-essential staff, long term local environment or reputation damage',
          'Potential loss of operations in area of country, medium term local environmental  or reputation damage',
          'Short term local'
        ],
        [ #'Medical/injury'
          'Suicide, life threatening injury, death  by contagious  disease',
          'Serious non-life threatening  injury to multiple personnel, attempted suicide, accidental death',
          'Death by natural cause, moderate or serious injury non-life threatening',
          'Minor injury',
          'Normal routine  problems for the context'
        ],
        [ #'Natural phenomenon within program context'
          'Event with multiple deaths',
          'Event with multiple injuries and damage',
          'Event with damage and no serious injuries',
          'Unusual event that affects operations – no  injuries some damage',
          'Routine event for the context'
        ],
        [ #'Other events'
          'Country wide anarchy',
          'Loss of staff contact or government detention >72 hrs,  widespread rioting, looting civil unrest',
          'Staff in accident that kills a national, loss of staff contact <72hrs, government detention 12hrs to 72hrs, bloodless coup, racial targeting, localised rioting',
          'Staff in accident that injures a national,  government detention <12hrs, political unrest, rallies',
          'Normal routine  problems for the context'
        ]
      ]
    },

    severity_table_dict: {
      0 => 'Catastrophic A',
      1 => 'Hazardous B',
      2 => 'Major C',
      3 => 'Minor D',
      4 => 'Negligible E',
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
      row_header: ['Almost Certain', 'Likely', 'Possible', 'Unlikely', 'Remote'],
      column_header_name: '',
      column_header: ['Frequency'],
      rows: [
        ['Occurs weekly'],
        ['Occurs monthly'],
        ['Occurs annually'],
        ['Occurs once in 10 years'],
        ['Theoretically possible'],
      ]
    },

    probability_table_dict: {
      0 => 'Frequent 5',
      1 => 'Occasional 4',
      2 => 'Remote 3',
      3 => 'Improbable 2',
      4 => 'Extremely Improbable 1',
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
      row_header: ['Almost Certain', 'Likely', 'Possible', 'Unlikely', 'Remote'],
      column_header_name: 'SEVERITY',
      column_header: ['Catastrophic', 'Major', 'Moderate', 'Minor', 'Negligible'],
      rows_color: [
        ['red',       'red',       'coral',       'yellow',    'yellow'],
        ['red',       'coral',     'yellow',      'yellow',  'steelblue'],
        ['coral',     'yellow',    'yellow',    'steelblue', 'steelblue'],
        ['yellow',    'yellow',    'steelblue', 'steelblue', 'steelblue'],
        ['steelblue', 'steelblue', 'steelblue', 'steelblue', 'steelblue']
      ],
    },

    risk_definitions: {
      red:       {rating: "Extreme Risk", description: "Requires Immediate Action"   },
      coral:     {rating: "High Risk",    description: "Requires Action within 10 days"   },
      yellow:    {rating: "Medium Risk",  description: "Requires Action within 120 days"   },
      steelblue: {rating: "Low Risk",     description: "May only require regular monitoring or action"   },
    },

    risk_table_index: {
      'Low Risk'      => 'steelblue',
      'Medium Risk'   => 'yellow',
      'High Risk'     => 'coral',
      'Extreme Risk'  => 'red',
    },

    risk_table_dict: {
      steelblue:  'Low Risk',
      yellow:     'Medium Risk',
      coral:      'High Risk',
      red:        'Extreme Risk',
    }
  }
end
