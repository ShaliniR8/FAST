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

      orientation: :vertical,
      direction: :down,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'RATING',
      row_header: ['0', '1', '2', '3', '4'],
      column_header_name: 'SEVERITY LEVELS',
      column_header: ['PHYSICAL INJURY','SAFETY OF FLIGHT','DAMAGE TO ASSETS','POTENTIAL INCREASED COST OR REVENUE LOSS','OPERATIONAL RELIABILITY'],
      rows: [
          ['NO INJURY',      'NO EFFECT',       'NO DAMAGE',               'NO INCREASED COST OR LOST REVENUE',       'NO EFFECT' ],
          ['MINOR INJURY',   'MARGIN DEGRADED', 'MINOR DAMAGE < US $50K',  'MINOR LOSS < US $50K',                    'DELAYS' ],
          ['SERIOUS INJURY','INCIDENT POTENTIAL','SUBSTANTIAL DAMAGE < US $250K','SUBSTANTIAL LOSS < US $250K', 'CANCELLATION' ],
          ['SINGLE FATALITY','ACCIDENT POTENTIAL','MAJOR DAMAGE < US $1M',  'MAJOR LOSS < US $1M',   'REGIONAL SCHEDULE IMPACT'],
          ['MULTIPLE FATALITIES','LOSS OF AIRCRAFT','CATASTROPHIC DAMAGE > US $1M','MASSIVE LOSS > US $1M','SYSTEMWIDE SCHEDULE IMPACT']
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
      orientation: :horizontal,
      direction: :up,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',
      row_header: ['Meaning'],
      column_header_name: 'Qualitative Definition',
      column_header: ['(A) Improbable' , '(B) Seldom', '(C) Occasional', '(D) Probable', '(E) Frequent'   ],
      row_header_name: 'Meaning',

      rows: [
        [
          #1
           'A remote likelihood, being almost inconceivable that event will occur </br>
            Quantitative - Greater than or equal to 10<sup>-6</sup> (1/1,000,000) or once per 10 years',
          #2
            'Very unlikely to occur (not known it has occured) </br>
            An activity or event that occurs intemittently </br>
            Regulator/Auditor have low likelihood of issue identification during any general or focused review </br>
            Quantitative - Greater than or equal to 10<sup>-5</sup> (1/100,000) or once per year',
          #3
            'Unlikely, but possible to occur (occurs rarely) </br>
            An activity or event that occurs infrequently, or irregularly. Sporadic in nature </br>
            Auditor/Regulator have potential of issue discovery during focused or specialized review </br>
            Quantitative - Greater than or equal to 10<sup>-4</sup> or once per month',
          #4
            'Likely to occur sometimes (occurs infrequently) </br>
            Will occur often if events follow normal patterns of process or procedure. Event is repeatable. </br>
            Auditor/Regulator have potential of issue discovery with minimal audit activity </br>
            Quantitative - Greater than or equal to 10<sup>-3</sup> (1/1000) or once per week',
          #5
            'Likely to occur many times (occurs frequently) </br>
            Will be continuously experienced unless action is taken to change events </br>
            Quantitative - Greater than or equal to 10<sup>-2</sup> (1/100) or once per day',
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

      row_header_name: 'RATING',
      row_header: ['0', '1', '2', '3', '4'],
      column_header_name: 'LIKELIHOOD LEVELS',
      column_header: [
        'A <br> IMPROBABLE',
        'B <br> SELDOM',
        'C <br> OCCASIONAL',
        'D <br> PROBABLE',
        'E <br> FREQUENT'],
      rows_color: [
        ['limegreen',   'limegreen',    'limegreen',    'limegreen',    'limegreen'],
        ['limegreen',   'limegreen',    'limegreen',    'limegreen',    'limegreen'],
        ['limegreen',   'limegreen',    'yellow',       'yellow',       'red' ],
        ['limegreen',   'yellow',       'yellow',       'red',          'red' ],
        ['yellow',      'yellow',       'red',          'red',          'red' ],
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
      limegreen:    { rating: 'LOW RISK'},
      yellow:       { rating: 'MEDIUM RISK' },
      red:          { rating: 'HIGH RISK' },
    },
  }

end
