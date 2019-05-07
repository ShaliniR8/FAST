class BOE_Config

  def self.airline_config
    {
      :version                                        => "1.0.2",

      :code                                           => "BOE",
      :time_zone                                      => "Central Time (US & Canada)",

      :base_risk_matrix                               => false,
      :event_summary                                  => true,
      :event_tabulation                               => true,
      :enable_configurable_risk_matrices              => false,
      :allow_set_alert                                => false,
      :has_verification                               => false,
      :has_mobile_app                                 => false,
      :enable_mailer                                  => true,



      # Safety Reporting Module
      :submission_description                         => true,
      :submission_time_zone                           => true,
      :enable_orm                                     => false,
      :observation_phases_trend                       => false,
      :allow_template_nested_fields                   => false,
      :checklist_version                              => '3',

      # Safety Assurance Module
      :allow_reopen_report                            => true,
      :has_root_causes                                => true,


      # SMS IM Module
      :has_framework                                  => false,
    }
  end


  FAA_INFO = {
    "CHDO"=>"ACE-FSDO-09",
    "Region"=>"Central",
    "ASAP MOU Holder Name"=>"Boeing",
    "ASAP MOU Holder FAA Designator"=>"BASE"
  }


  MATRIX_INFO = {
    severity_table: {
      starting_space: true,
      row_header: ['5','4','3','2','1'],
      column_header: [
        'Safety (Impact)',
        'People (Injury)',
        'Security (Threat)',
        'Environment (Effect)',
        'Assets (Damage)'],
      rows: [
        [
          'Massive',
          'Fatality/Disability',
          'Extreme',
          'Catastrophic',
          'Massive'
        ],
        [
          'Major',
          'Major',
          'High',
          'Major',
          'Major'
        ],
        [
          'Minor',
          'Minor',
          'Medium',
          'Moderate',
          'Minor'
        ],
        [
          'Slight',
          'Slight',
          'Low',
          'Minor',
          'Slight'
        ],
        [
          'Negligible',
          'Negligible',
          'Negligible',
          'Negligible',
          'Negligible'
        ]
      ]
    },

    severity_table_dict: {
      0 => "5",
      1 => "4",
      2 => "3",
      3 => "2",
      4 => "1"
    },

    probability_table: {
      starting_space: true,
      row_header: [''],
      column_header: ['A','B','C','D','E'],
      rows: [
        [
          'Improbable (10 Years)',
          'Remote (5 Years)',
          'Occasional (1 Year)',
          'Probable (6 Months)',
          'Frequent (30 Days)'
        ]
      ]
    },

    probability_table_dict: {
      0 => 'Improbable (10 Years)',
      1 => 'Remote (5 Years)',
      2 => 'Occasional (1 Year)',
      3 => 'Probable (6 Months)',
      4 => 'Frequent (30 Days)'
    },

    risk_table: {
      starting_space: true,
      row_header: ['5','4','3','2','1'],
      column_header: ['A','B','C','D','E'],
      rows: [
        ['yellow','red','red','red','red'],
        ['yellow','yellow','red','red','red'],
        ['limegreen','yellow','yellow','yellow','red'],
        ['limegreen','limegreen','yellow','yellow','yellow'],
        ['limegreen','limegreen','limegreen','yellow','yellow']

      ]
    },

    risk_definitions: {
      red:       {rating: "HIGH",     cells: "A4, A3, B4",     description: "Unacceptable"                 },
      yellow:    {rating: "MODERATE", cells: "A2, B2, C4",     description: "Acceptable with Mitigation"   },
      limegreen: {rating: "LOW",      cells: "A1, B2, C3, D4", description: "Acceptable"                   },
    },

    risk_table_index: {
      red:        "High",
      yellow:     "Moderate",
      limegreen:  "Low"
    },

    risk_table_dict: {
      red:        "High",
      yellow:     "Moderate",
      limegreen:  "Low"
    }
  }

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
      return list.map(&:to_i).last
    end
  end

  def self.print_severity(owner, severity_score)
    MATRIX_INFO[:severity_table_dict][severity_score] unless severity_score.nil?
  end

  def self.print_probability(owner, probability_score)
    MATRIX_INFO[:probability_table_dict][probability_score] unless probability_score.nil?
  end

  def self.print_risk(probability_score, severity_score)
    if !probability_score.nil? && !severity_score.nil?
      lookup_table = MATRIX_INFO[:risk_table][:rows]
      return MATRIX_INFO[:risk_table_dict][lookup_table[severity_score][probability_score].to_sym]
    end
  end

end
