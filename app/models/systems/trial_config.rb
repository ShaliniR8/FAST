class Trial_Config

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  def self.airline_config
    {
      :version                                        => "1.0.3",

      :name                                           => 'ProSafeT Trial',
      :code                                           => "BOE",
      :base_risk_matrix                               => true,
      :event_summary                                  => false,
      :event_tabulation                               => false,
      :enable_configurable_risk_matrices              => true,
      :allow_set_alert                                => true,
      :has_extension                                  => true,
      :has_verification                               => true,
      :has_mobile_app                                 => true,
      :enable_mailer                                  => false,
      :track_log                                      => true,
      :time_zone                                      => 'Pacific Time (US & Canada)',

      # Safety Reporting Module
      :submission_description                         => true,
      :submission_time_zone                           => true,
      :enable_orm                                     => true,
      :observation_phases_trend                       => false,
      :allow_template_nested_fields                   => true,
      :checklist_version                              => '3',

      # Safety Assurance Module
      :allow_reopen_report                            => false,
      :has_root_causes                                => true,
      :enable_recurrence                              => true,


      # SMS IM Module
      :has_framework                                  => false,
    }
  end

  FAA_INFO = { #CORRECT/REVISE
    "CHDO"=>"ProSafeT",
    "Region"=>"Pacific",
    "ASAP MOU Holder Name"=>"ProSafeT",
    "ASAP MOU Holder FAA Designator"=>"ProSafeT"
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
