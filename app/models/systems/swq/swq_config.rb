class SWQConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'iAero Airways',
    time_zone:                    'Mountain Time (US & Canada)',

    enable_sso:                         true,
    login_option:                       'dual',
    advanced_checklist_data_type:  true,

    # SYSTEM CONFIGS
    global_admin_default:          false,
    sms_im_visibility:             false,
  })

  MATRIX_INFO = {
    terminology: {
      baseline_btn: 'Baseline Risk',
      mitigate_btn: 'Mitigate Risk',
      'Baseline' => 'Baseline',
      'Mitigate' => 'Mitigated'
    },

    severity_table: {
      title: 'SEVERITY',

      orientation: :horizontal,
      direction: :right,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: '',
      row_header: [
        '0',
        '1',
        '2',
        '3',
        '4',
      ],
      column_header_name: 'Areas for Consideration',
      column_header: ['Outcome', 'Safety of Flight', 'Physical Injury', 'Regulatory Compliance','Financial Impact (USD)', 'Operational Impact'],
      rows: [
        ["Negligible", "No Impact", "No Injury", "No Effect", "No Cost", "No Impact"],
        ["Minor", "Margin Degraded", "Minor Injury", "Minor Regulatory Issue", "< $50k", "Delays"],
        ["Major", "Incident Potential", "Serious Injury", "Significant Regulatory Issue", "$50k to $250k", "Flight Cancellation"],
        ["Hazardous", "Accident Potential", "Single Fatality", "Fines or Operating Restriction", "$250k to $1M", "Multiple Cancellations"],
        ["Catastrophic", "Loss of Aircraft", "Multiple Fatalities", "Criminal Charges or Certificate Action", "> $1M", "Fleet-Wide Grounding"],
      ]
    },

    severity_table_dict: {
      0 => 'Outcome',
      1 => 'Safety of Flight',
      2 => 'Physical Injury',
      3 => 'Financial Impact (USD)',
      4 => 'Catastrophic',
      5 => 'Operational Impact',
    },

    probability_table: {
      title: 'LIKELIHOOD',

      orientation: :vertical,
      direction: :down,
      size: 'col-xs-6',
      title_style: 'probabilityTitle',
      main_header_style: 'probMainHeader',
      header_style: 'probHeader',
      cell_name: 'probability_td',

      row_header_name: 'Likelihood Definitions',
      row_header: ['Improbable', 'Seldom', 'Occasional', 'Probable', 'Frequent'],
      column_header_name: '',
      column_header: [''],
      rows: [
        ["A remote likelihood, almost inconceivable that event will occur (has not happened before)<br>
         Auditors/Regulators have very low likelihood of non-conformance discovery during a specialized or focused review<br>
         Quantitative - Greater than or equal to 1 in 1,000,000, or once every ten years"],
        ["Very unlikely to occur (if existing issue, occurred only once or twice). An activity or event that occurs intermittently, not likely to happen (but could)<br>
         Auditors/Regulators have low likelihood of non-conformance discovery during any general or focused review<br>
         Quantitative - Greater than or equal to 1 to 100,000, or once a year"],
        ["Unlikely, but possible to occur (if existing issue, occurs rarely). An activity or event that occurs infrequently or irregularly<br>
         Auditors/Regulators have potential of non-conformance discovery during focused or specialized review<br>
         Quantitative - Greater than or equal to 1 in 10,000, or once a month"],
        ["Likely to occur sometimes (if existing issue, occurs infrequently). Will occur often if events follow normal patterns. Event is repeatable and less sporadic<br>
         Auditors/Regulators have potential of non-conformance discovery with light audit activity<br>
         Quantitative - Greater than or equal to 1 in 1,000, or once a week"],
        ["Likely to occur many times (if existing issue, occurs frequently). Will be continuously experienced unless action is taken to change events<br>
         Auditors/Regulators have potential of non-conformance discovery with minimal audit activity<br>
         Quantitative - Greater than or equal to 1 in 100, or once a day"],
      ]
    },

    probability_table_dict: {
      0 => 'Improbable',
      1 => 'Seldom',
      2 => 'Occasional',
      3 => 'Probable',
      4 => 'Frequent',
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

      row_header_name: 'Severity Levels',
      row_header: ['A<br>Improbable', 'B<br>Seldom', 'C<br>Occasional', 'D<br>Probable', 'E<br>Frequent'],
      column_header_name: 'Likelihood Levels',
      column_header: ['0', '1', '2', '3','4'],
      rows: [
        ['A0',   'B0',    'C0',    'D0',    'E0' ],
        ['A1',   'B1',    'C1',    'D1',    'E1' ],
        ['A2',   'B2',    'C2',    'D2',    'E2' ],
        ['A3',   'B3',    'C3',    'D3',    'E3' ],
        ['A4',   'B4',    'C4',    'D4',    'E4' ]
      ],
      rows_color: [
        ['limegreen',      'limegreen',      'limegreen',      'limegreen',      'limegreen'],
        ['limegreen',      'limegreen',      'limegreen',      'yellow',         'yellow'],
        ['limegreen',      'limegreen',      'yellow',         'yellow',         'red'],
        ['limegreen',      'yellow',         'yellow',         'red',            'red'],
        ['yellow',         'yellow',         'red',            'red',            'red']
      ],
    },

    risk_definitions: {
      limegreen: {rating: "LOW",    description: "Acceptable" },
      yellow:    {rating: "MEDIUM", description: "Acceptable with Mitigation" },
      red:       {rating: "HIGH",   description: "Unacceptable" },
    },

    risk_table_index: {
      'LOW'    => 'limegreen',
      'MEDIUM' => 'yellow',
      'HIGH'   => 'red',
    },

    risk_table_dict: {
      limegreen:  'LOW',
      yellow:     'MEDIUM',
      red:        'HIGH',
    }
  }
end
