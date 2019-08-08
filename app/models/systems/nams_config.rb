class NAMS_Config

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  def self.airline_config
    {
      :version                                        => "1.0.3",
      :code                                           => "NAMS",
      :name                                           => 'Northern Air Cargo',
      :base_risk_matrix                               => false,
      :event_summary                                  => false,
      :event_tabulation                               => false,
      :enable_configurable_risk_matrices              => false,
      :allow_set_alert                                => false,
      :has_verification                               => false,
      :has_mobile_app                                 => true,
      :enable_mailer                                  => true,
      :time_zone                                      => 'Alaska',


      # Safety Reporting Module
      :submission_description                         => true,
      :submission_time_zone                           => true,
      :enable_orm                                     => false,
      :observation_phases_trend                       => false,
      :allow_template_nested_fields                   => false,
      :checklist_version                              => '1',

      # Safety Assurance Module
      :allow_reopen_report                            => false,
      :has_root_causes                                => false,
      :enable_recurrence                              => false,
      :enable_shared_links                            => false,


      # SMS IM Module
      :has_framework                                  => false,
    }
  end


  OBSERVATION_PHASES = ["Observation Phase", "Condition", "Threat", "Error", "Human Factor", "Comment"]



  FAA_INFO = {
    "CHDO"=>"FAA Flight Standards District Office, 300W 36th Ave, Suite 101, Anchorage, AK, 99503",
    "Region"=>"Anchorage",
    "ASAP MOU Holder Name"=>"N/A",
    "ASAP MOU Holder FAA Designator"=>"N/A"
  }



  MATRIX_INFO = {
    severity_table: {
      starting_space: true,
      column_header: ['I','II','III','IV'],
      row_header: [ 'Accident or Incident',
                    'Employee or Customer Injury',
                    'Aircraft Operational Events',
                    'Airworthiness',
                    'Documented Systems, Policies, and Processes',
                    'Audit Finding',
                    'Security',
                    'HSE / Other Regulatory or General Issue',
                  ],

      rows: [
        [
          'Accident with serious injuries or fatality; aircraft hull loss; loss of property',
          'Accident or incident with serious injury; substantial damage to aircraft or property',
          'Incident with minor injuries; minor damage to aircraft or property',
          'Incident with no injuries; cosmetic damage to aircraft or property',
        ],
        [
          'Fatality or serious injury resulting in permanent disability / loss of capacity',
          'Emergency care required; hospitalization; temporary disability / loss of capacity',
          'Non-emergency medical care required',
          'Minor injury; no medical treatment required'
        ],
        [
          'Impacts the immediate safe operation of an aircraft',
          'Impacts the continued safe operation of an aircraft',
          'May impact the safe operation of an aircraft',
          'May impact normal operation of an aircraft',
        ],
        [
          'Aircraft returned to service and operated in an un-airworthy, or unsafe condition',
          'Aircraft returned to service and operated in an un-airworthy, but not unsafe condition',
          'Aircraft returned to service in an un-airworthy and unsafe condition, but not operated',
          'Aircraft returned to service in an un-airworthy condition, but not considered unsafe and not operated',
        ],
        [
          'Loss or breakdown of entire system',
          'Loss or breakdown of process; non-compliance with regulatory policies',
          'Deficiencies leading to poor dependability or disruption of processes; non-conformance with organizational policies',
          'Procedural inconsistencies resulting in conflicting or unclear instructions',
        ],
        [
          'Immediate Safety Concern / Violation',
          'Regulatory Non-Compliance',
          'Non-Conformance with organizational policies / procedures',
          'Concern',
        ],
        [
          'Willful',
          'Repeat',
          'Serious',
          'Inadvertent',
        ],
        [
          'Willful and/or major regulatory violation',
          'Repeat and/or moderate regulatory deviation',
          'Serious and/or organizational policy / procedure non-compliance',
          'General / Other',
        ]
      ]
    },

    severity_table_dict: {
      0 => "I",
      1 => "II",
      2 => "III",
      3 => "IV",
    },

    probability_table: {
      starting_space: true,
      row_header: ['A', 'B', 'C', 'D'],
      column_header: ['Audit Findings', 'Events'],

      rows: [
        [
          'Multiple findings on current and previous audit',
          'Occurs or expacted to occur repeatedly until action is taken to mitigate the cause; follows a known trend or pattern',
        ],
        [
          'Multiple findings on current audit',
          'Occurs or may occur regularly (within the last year) if no action is taken to mitigate the cause; may repeat; identified by trends or pattern',
        ],
        [
          'Single finding on current audit and previous audit',
          'Occurs or may occur infrequently (within the last 5 years); unlikely to repeat; difficult to predict by current treads or patterns',
        ],
        [
          'Single finding on current audit / Concern',
          'One-time isolated event; not expected to repeat; not detectable by current trends or patterns',
        ],
      ]
    },

    probability_table_dict: {
      0 => 'A',
      1 => 'B',
      2 => 'C',
      3 => 'D',
    },

    risk_table: {
      starting_space: true,
      column_header: ['I','II','III','IV'],
      row_header: ['A', 'B', 'C', 'D'],
      rows: [
        ['crimson',     'crimson',          'coral',              'yellow'              ],
        ['crimson',     'coral',            'yellow',               'mediumseagreen'    ],
        ['coral',       'yellow',             'yellow',               'mediumseagreen'    ],
        ['yellow',      'mediumseagreen',   'mediumseagreen',     'mediumseagreen'    ],
      ]
    },


    risk_table_dict: {
      crimson:        "Red (A/I, A/II, B/I) - HIGH",
      coral:          "Orange (A/III, B/II, C/I) - SERIOUS",
      yellow:         "Yellow (A/IV, B/III, C/II, C/III, D/I) - MODERATE",
      mediumseagreen: "Green (B/IV, C/IV, D/II, D/III, D/IV) - LOW"
    },

    risk_table_index: {
      crimson:        "HIGH",
      coral:          "SERIOUS",
      yellow:         "MODERATE",
      mediumseagreen: "LOW"
    },

    risk_definitions: {
      crimson:          {rating: "HIGH",      cells: "A/I, A/II, and B/I",                    description: ""},
      coral:            {rating: "SERIOUS",   cells: "A/III, B/II, and C/I",                  description: ""},
      yellow:           {rating: "MODERATE",  cells: "A/IV, B/III, C/II, C/III, and D/I",     description: ""},
      mediumseagreen:   {rating: "LOW",       cells: "B/IV, C/IV, D/II, D/III and D/IV",      description: ""}
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
    if !probability_score.nil? && !severity_score.nil?
      lookup_table = MATRIX_INFO[:risk_table][:rows]
      return MATRIX_INFO[:risk_table_index][lookup_table[severity_score][probability_score].to_sym] rescue nil
    end
  end

end
