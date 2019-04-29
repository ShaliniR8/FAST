class JUS_Config


  def self.airline_config
    {
      :version                                        => "1.0.2",

      :code                                           => "JUS",
      :base_risk_matrix                               => true,
      :has_analytics_filter                           => true,
      :enable_message_mailer                          => true,
      :enable_message_templates                       => true,
      :event_summary                                  => true,
      :event_tabulation                               => true,
      :enable_custom_options                          => true,
      :enable_configurable_risk_matrices              => true,
      :enable_checklist_templates                     => true,
      :allow_set_alert                                => true,
      :has_verification                               => true,
      :has_mobile_app                                 => false,



      # Safety Reporting Module
      :allow_anonymous_submission                     => true,
      :submission_description                         => true,
      :submission_time_zone                           => true,
      :submission_mailer                              => true,  # Notifier will be notified on receiving new submissions
      :allow_multi_submissions                        => true,
      :view_narrative_from_meeting                    => true, # Show report narratives from the meeting page
      :enable_orm                                     => true,
      :observation_phases_trend                       => true,
      :submission_title_required                      => true,
      :allow_template_nested_fields                   => true,
      :checklist_version                              => '2',

      # Safety Assurance Module
      :sa_mailer                                      => true,
      :allow_reopen_report                            => true,
      :has_root_causes                                => true,


      # SMS IM Module
      :has_framework                                  => false,
      :sra_mailers                                    => true,
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
      row_header: ['Aircraft Accident','Personnel Health and Safety','Regulatory','Security','Environment'],
      column_header: ['Critical = 5', 'Serious = 3', 'Minor = 1'],

      # Trevor on 4/2/2018
      rows: [
        [
          'Aircraft Accident, as defined in 49CFR§830.2',
          'Aircraft Incident, as defined in 49CFR§830.2',
          'Aircraft damage event that does not qualify as incident or accident',
        ],
        [
          'Fatality, seious injury, or permanent disability. Company personnel or public.',
          'Prolonged lost time work injury, temporary disability. Company personnel or public.',
          'First aid injury or occupational illness. Company personnel or public.',
        ],
        [
          'Violation of applicable regulation(s) that may result in civil/criminal penalty or loss or air carrier\'s certificate.',
          'Non-compliance likely to require Corrective Action Plan, but no civil or criminal penalty.',
          'Violation of non-regulatory company policy or procedure.',
        ],
        [
          'Aircraft theft/tampering, hijack/commandeering, bomb or bomb threat, sabotage, terrorist activity. Felony violation of laws or TSA Regulations.',
          'Non-compliance likely to require Corrective Action Plan or Regulator\'s Administrative Action',
          'Violation of non-regulatory company policy or procedure.',
        ],
        [
          'Violation of Federal or State regulations, or spill or other release of a regulated substance in a reportable quantity.',
          'Violation of Federal or State regulations, or spill or other release of a regulated substance in a non-reportable quantity.',
          'Violation of non-regulatory Company policy, or easily contained spill or release of a non-regulated substance.',
        ]
      ]
    },

    severity_table_dict: {
      0 => "Critical = 5",
      1 => "Serious = 3",
      2 => "Minor = 1",
    },

    probability_table: {
      starting_space: true,
      row_header: ['History', 'Hazard Forecast'],
      column_header: ['High = 5','Medium = 3','Low = 1'],
      rows: [
        [
          'Hazard previously identified multiple (>3) times in USA Jet operations, or in industry, previously.',
          'This type of hazard previously identified 1-3 times at USAJ, or in industry.',
          'Hazard not known to have been identified previously in USAJ operations, or in industry.',
        ],
        [
          'Exposure to hazard likely, if not mitigated.',
          'Possible, but unlikely exposure to hazard, if not mitigated.',
          'Highly doubtful that the hazard will recur, even with no mitigation.',
        ],
      ]
    },

    probability_table_dict: {
      2 => 'Low = 1',
      1 => 'Medium = 3',
      0 => 'High = 5',
    },

    risk_table: {
      starting_space: true,
      column_header: ['Critical = 5','Serious = 3','Minor = 1'],
      row_header: ['High = 5','Medium = 3','Low = 1'],
      rows: [
        ['red',     'yellow',       'limegreen'],
        ['red',     'yellow',       'limegreen'],
        ['red',     'limegreen',    'limegreen'],
      ]
    },

    risk_definitions: {
      red:        {rating: "HIGH",          description: "Not Acceptable - Mitigation Required"},
      yellow:     {rating: "MODERATE",      description: "Acceptable with Mitigation Plan"},
      limegreen:  {rating: "LOW",           description: "Acceptable with Monitoring"}
    },

    risk_table_dict: {
      red:            "HIGH",
      yellow:         "MODERATE",
      limegreen:      "LOW"
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
      return MATRIX_INFO[:risk_table_dict][lookup_table[probability_score][severity_score].to_sym]
    end
  end
end
