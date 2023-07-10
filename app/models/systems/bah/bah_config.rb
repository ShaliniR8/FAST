class BAHConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Bahrain Airport Company',
    time_zone:                    'Riyadh',
    has_pdf_logo:                  true,
    has_pdf_footer:                  true,

    # SYSTEM CONFIGS
    advanced_checklist_data_type:  true,
    checklist_query:               true,

    has_gmap:                      true,
    gis_layers:                    true,

    lat:                           26.270101,
    lng:                           50.632009,
    gMapZoom:                      14,

    global_admin_default:          false,
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
      direction: :right,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      column_header_name: 'Severity / Consequence – Scope of Damage',
      column_header: ['Negligible A', 'Minor B', 'Moderate C', 'Major D', 'Catastrophic E'],
      row_header_name: 'Rank',
      row_header: [
        'Operations',
        'Health & Safety',
        'Environment',
        'Reputation',
        'Governance and Regulatory'],
      rows: [
        # Operations
        [
          'No Damage Nuisance',
          'Minor damage to an aircraft, equipment, or facility not requiring it to be taken out of service; or Minimal unplanned airport operations limitations (i.e., taxiway closure); or Minor incident involving the use of airport emergency procedures',
          "Damage to an aircraft that is repairable. Damage to equipment or facility that is reparable within a short period of time; or Significant reduction in safety margins; or Deduction on the airport's ability to deal with adverse conditions; or Reduction in the ability to cope with adverse operating conditions as a result of an increase in workload or as a result of conditions impairing their efficiency",
          'Damage to an aircraft taking it out of service for an extended period of time for repair; or Disruption of critical services for extended period of time; or Complete unplanned airport closure, or major unplanned operations limitations (i.e.. runway closure)',
          'Loss of an aircraft; or Loss of critical system(s) for an extended period of time; or Complete unplanned airport closure and destruction of critical facilities'
        ],
        #Health & Safety
        [
          'No or minor injury (basic first aid treatment)',
          'Minor injury or occupational illness',
          'Serious non-permanent injuries requiring medical treatment',
          'Permanent disability or Severe injuries, requiring hospitalization',
          'Fatalities'
        ],
        #Environment
        [
          'No or negligible impact on the environment, or<br><br>
          no or insignificant impact on air quality, or<br><br>
          low noise',

          'A spill or release that does not require a report, or<br><br>
          minor impact on air quality, or<br><br>
          low noise',

          'A reportable spill or release that is contained, or<br><br>
          moderate impact on air quality, or<br><br>
          moderate noise level',

          'A reportable spill or release that requires mitigation, or<br><br>
          high impact on air quality, or<br><br>
          high noise level',

          'A spill or release that is not contained and results in long term damage to the environment and fines to the airport, or<br><br>
          very high impact on air quality, or<br><br>
          high noise levels'
        ],
        #Reputation
        [
          'Noticed internally, no public and/or media attention. Negligible or Isolated staff dissatisfaction. Insignificant impact on BAC’s reputation. No impact on stakeholder relations.',
          'Noticed internally, no public and/or media attention. Negligible or Isolated staff dissatisfaction. Insignificant impact on BAC’s reputation as employer. No impact on customer and stakeholder relations.',
          'Rumors and speculations, short term unease. Some community / customer concerns raised. Minor public relations issue.',
          'Some national media coverage, considerable community concern and limited community / customer complaints. Negative press article in GCC media. Minor impact on stakeholder relationship (i.e. minor written stakeholder complaints).',
          'Major public or media outcry; sustained, adverse and prolonged local / international / social media coverage. Loss of stakeholder.'
        ],
        #Governance and Regulatory
        [
          'Isolated, quickly remedied noncomplianc e with best practices, or national laws, international and local regulations.',
          'Isolated, slowly remedied noncompliance with best practices, or national laws, or international and local regulations.',
          'Repeated, slowly remedied noncompliance with best practices, or national laws, or international and local regulations.',
          'Substantial, unmeasurable noncompliance with national laws, or international and local regulations System resulting in questioning the reliability of Bahrain International Airport services and loss of customers.',
          'Substantial, noncompliance with international and local regulations resulting in questioning the reliability of Bahrain International Airport services and state decision to suspend the airport operations.'
        ]
      ]
    },

    severity_table_dict: {
      0 => "4",
      1 => "3",
      2 => "2",
      3 => "1",
      4 => "0",
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

      row_header_name: 'Rank',
      row_header: ['5', '4', '3', '2', '1'],
      column_header_name: 'Probability that an accident / damage occurs',
      column_header: [''],

      rows: [
        [ #5
          "<center><b>Frequent</b></center>Likely to occur many times - has occurred frequently<br>- Once in less than a year"
        ],
        [ #4
          "<center><b>Likely</b></center>Likely to occur sometimes - has occurred infrequently<br>- Once in a year"
        ],
        [ #3
          "<center><b>Remote</b></center>Unlikely to occur, but possible - has occurred rarely<br>- Once in 2 years"
        ],
        [ #2
          "<center><b>Unlikely</b></center>Very unlikely to occur - not known to have occurred<br>- Once in 3 to 4 years"
        ],
        [ #1
          "<center><b>Rare</b></center>Almost inconceivable that the event will occur<br>- Once in 5 years"
        ]
      ] #End of rows
    },

    probability_table_dict: {
      0 => 'A - Improbable',
      1 => 'B - Unlikely',
      2 => 'C - Remote',
      3 => 'D - Probable',
      4 => 'E - Frequent',
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

      column_header_name: 'SEVERITY',
      column_header: ['Negligible A', 'Minor B', 'Moderate C', 'Major D', 'Catastrophic E'],
      row_header_name: 'PROBABILITY',
      row_header: ['Frequent 5', 'Likely 4', 'Remote 3', 'Unlikely 2', 'Rare 1'],

      rows_color: [
        ['yellow',     'orange',     'orange',     'red',      'red'],
        ['yellow',     'yellow',     'orange',     'orange',   'red'],
        ['limegreen',  'yellow',     'yellow',     'orange',   'orange'],
        ['limegreen',  'limegreen',  'yellow',     'yellow',   'orange'],
        ['limegreen',  'limegreen',  'limegreen',  'yellow',   'yellow']
      ],
    },

    risk_definitions: {
      red:   {
        rating: 'Very High',
        description: "<b>Intolerable:</b> Safety is not ensured. Enhanced protective measures are urgently required. Immediate action required by Executive Management with detailed planning, allocation of resources, and regular monitoring.
        <br><br>
        <b>Action</b>: Immediate attention required by BAC CEO, with detailed planning and allocation of resources." },
      orange:      {
        rating: 'High',
        description: "<b>Undesirable:</b> Safety is not ensured. Protective measures are urgently required. Management responsibility must be specific.
        <br><br>
        <b>Action:</b> Direct involvement from Manager - Aerodrome Safety required, and regular monitoring."
      },
      yellow:      {
        rating: 'Moderate',
        description: "<b>ALaRP:</b> Safety is partially guaranteed. Normal protective measures are required, Acceptable based on risk mitigation, provided it has been reduced to a level which is “As Low as Reasonably Practicable (ALaRP). Regular supervision by Manager - Aerodrome Safety, and performance monitoring of the implementation of the routine safety procedures.
      <br><br>
      <b>Action:</b> Allocation of responsibility by Manager - Aerodrome Safety must be specified"
      },
      limegreen:         {
        rating: 'Low',
        description: "<b>Acceptable:</b> Safety is largely guaranteed. Organizational and staff-related measures may still be required. Managed by routine procedures.
        <br><br>
        <b>Action:</b> Monitor and manage through routine procedures"
      },
    },

    risk_table_index: {
      'Orange - Unacceptable'                => 'orange',
      'Yellow - Acceptable with mitigation'  => 'yellow',
      'Green - Acceptable'                   => 'limegreen',
      'Red - Unacceptable'                   => 'red',

      'Orange'   => 'orange',
      'Yellow'   => 'yellow',
      'Green'    => 'limegreen',

      'Moderate' => 'yellow',
      'Low'      => 'limegreen',
      'High'     => 'red',

      'MODERATE' => 'yellow',
      'LOW'      => 'limegreen',
      'HIGH'     => 'red',
    },

    risk_table_dict: {
      limegreen:  'Green - Acceptable',
      red:        'Red - Unacceptable',
      yellow:        'Yellow - Acceptable with mitigation',
      orange:        'Orange - Unacceptable',

    }
  }

end
