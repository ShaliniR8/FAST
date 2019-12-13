class DefaultConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them, or copy the 'template' configs
    # All configs inherit from their Default counterparts, then overload the default values when needed

  # For linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  # For creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]
  # For selecting which modules are available to mobile; example would be %w[ASAP]
  MOBILE_MODULES = %w[]

  #############################
  ### GLOBAL CONFIGURATIONS ###
  #############################

  GENERAL = {
    # AIRLINE-SPECIFIC CONFIGS
      # Please Ensure these are filled out for each airline
    version:        '1.2.0 beta',                 # Helps to track most recent logged updates
    name:           'Not Initialized',            # Airline Name- shown throughout site
    time_zone:      'Pacific Time (US & Canada)', # Used in varied locations

    # SYSTEM CONFIGS
    enable_mailer:                      true,    # Enables emails to be sent via the system - default on
    enable_sso:                         false,   # Enables Single Sign-On integration (req. _sso_config) - default off
    has_mobile_app:                     false,   # Enables Mobile App Subsystems for app usage - default off
    track_log:                          false,   # Enables Daily Log Digest of User access/usage - default off

    # SYSTEM-WIDE FORM CONFIGS
    allow_reopen_forms:                 true,    # Indicates if forms can be reopened  - default on
    base_risk_matrix:                   true,    # Indicates the use of the default risk matrix - default on
    configurable_risk_matrices:         false,   # Enables the use of varied risk matrices - default off
    has_root_causes:                    true,    # Enables the use of root causes - default on
    shared_links:                       false,   # Enables shareable links to be created for forms - default off

    # TO BE REMOVED:
    allow_set_alert:                    false,   # Allows forms to use alerts (notifications to users/self)
    has_extension:                      false,   # Allows forms to request extensions
    has_verification:                   false,   # Allows forms to be verified (additional step)
  }

  def self.getTimeFormat
    {
      :timepicker       => 'H:i',
      :datepicker       => 'Y/m/d',
      :datetimepicker   => 'Y/m/d H:i',
      :dateformat       => '%Y/%m/%d',
      :datetimeformat   => '%Y/%m/%d %H:%M',
      :datetimezformat   => '%Y/%m/%d %H:%M %Z',
    }
  end

  def self.mobile_modules
    mobile_mobile_access = CONFIG::MOBILE_MODULES rescue ['ASAP', 'SMS']
    mobile_mobile_access.map{ |module_key| HIERARCHY[module_key][:display_name] }
  end

  FAA_INFO = {
    'CHDO'                           => 'CHDO Not Initialized',
    'Region'                         => 'Region Not Initialized',
    'ASAP MOU Holder Name'           => 'Holder Name Not Initialized',
    'ASAP MOU Holder FAA Designator' => 'Holder FAA Designator Not Initialized'
  }

  # To access Safety Reporting Configs use the constant defined below (use CONFIG.sr in code)
  def self.sr
    Object.const_get("#{AIRLINE_CODE}SafetyReportingConfig") rescue DefaultSafetyReportingConfig
  end

  # To access Implementation Management Configs use the constant defined below (use CONFIG.im in code)
  def self.im
    Object.const_get("#{AIRLINE_CODE}ImplementationManagementConfig") rescue DefaultImplementationManagementConfig
  end

  # To access Safety Assurance Configs use the constant defined below (use CONFIG.sa in code)
  def self.sa
    Object.const_get("#{AIRLINE_CODE}SafetyAssuranceConfig") rescue DefaultSafetyAssuranceConfig
  end

  # To access Safety Risk Management Configs use the constant defined below (use CONFIG.srm in code)
  def self.srm
    Object.const_get("#{AIRLINE_CODE}SafetyRiskManagementConfig") rescue DefaultSafetyRiskManagementConfig
  end

  # To access Mobile Configs use the constant defined below (use CONFIG.mobile)
  def self.mobile
    Object.const_get("#{AIRLINE_CODE}MobileConfig") rescue DefaultMobileConfig
  end

  # To access SSO Configs use the constant defined below (use CONFIG.sso)
  def self.sso
    Object.const_get("#{AIRLINE_CODE}SsoConfig") rescue DefaultSsoConfig
  end

  def self.hierarchy
    {
      'ASAP'    => self.sr::HIERARCHY,
      'SMS IM'  => self.im::HIERARCHY,
      'SMS'     => self.sa::HIERARCHY,
      'SRM'     => self.srm::HIERARCHY
    }
  end

  def self.object
    hierarchy.reduce({}){ |acc, (mod,data)| acc.merge(data[:objects]) }
  end

  def self.check_action(user,action,obj,**op)
    self.object[obj.class.name][:actions][action][:access].call(owner:obj,user:user,**op)
  end


  ###################################
  ### DEFAULT RISK MATRIX CONFIGS ###
  ###################################

  RISK_MATRIX = {
    :likelihood       => ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
    :severity         => (0..4).to_a.reverse,
    :risk_factor      => {"Green - Acceptable" => "lime", "Yellow - Acceptable with mitigation" => "yellow", "Orange - Unacceptable" => "orange"},
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
        [ 'Massive',    'Fatality/Disability',  'Extreme',     'Catastrophic',   'Massive'      ],
        [ 'Major',      'Major',                'High',        'Major',          'Major'        ],
        [ 'Minor',      'Minor',                'Medium',      'Moderate',       'Minor'        ],
        [ 'Slight',     'Slight',               'Low',         'Minor',          'Slight'       ],
        [ 'Negligible', 'Negligible',           'Negligible',  'Negligible',     'Negligible'   ]
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

  # Calculate the severity based on the airlines's risk matrix
  def self.calculate_severity(list)
    if list.present?
      list.delete("undefined") # remove "undefined" element from javascript
      return list.map(&:to_i).min
    end
  end

  # Calculate the probability based on the airlines's risk matrix
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
      return MATRIX_INFO[:risk_table_index][lookup_table[probability_score][severity_score].to_sym] rescue nil
    end
  end

end
