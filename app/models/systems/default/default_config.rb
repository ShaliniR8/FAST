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
    version:        '1.2.6',                      # Helps to track most recent logged updates
    name:           'Not Initialized',            # Airline Name- shown throughout site
    time_zone:      'Pacific Time (US & Canada)', # Used in varied locations


    # SYSTEM CONFIGS
    enable_mailer:                      true,    # Enables emails to be sent via the system - default on
    enable_sso:                         false,   # Enables Single Sign-On integration (req. _sso_config) - default off
    login_option:                       'prosafet', # Login page UI config => available options: dual, prosafet, sso
    has_mobile_app:                     false,   # Enables Mobile App Subsystems for app usage - default off
    track_log:                          false,   # Enables Daily Log Digest of User access/usage - default off
    cisp_integration:                   false,
    asrs_integration:                   false,
    sabre_integration:                  false,
    hide_asap_submissions_in_dashboard: false,
    has_pdf_footer:                     false,    # Enables custom airline footer
    power_bi_integration:               false,
    has_confidential_forms:             false,
    csv_user_import:                    false,
    checklist_query:                    false,

    # Map Configs. Needed in default config to avoid javascript undefined errors
    has_gmap:                           false,
    gis_layers:                         false,
    lat:                                0.0,
    lng:                                0.0,
    gMapZoom:                           14,

    # Third Party Integrations:
    integrations: ['mitre'],

    # SYSTEM-WIDE FORM CONFIGS
    allow_reopen_forms:                         true,    # Indicates if forms can be reopened  - default on
    base_risk_matrix:                           false,    # Indicates the use of the default risk matrix - default on
    configurable_risk_matrices:                 false,   # Enables the use of varied risk matrices - default off
    has_root_causes:                            true,    # Enables the use of root causes - default on
    shared_links:                               false,   # Enables shareable links to be created for forms - default off
    drop_down_risk_selection:                   false,
    query_processing_in_rake_task:              false,
    advanced_checklist_data_type:               false,
    auto_populate_nested_fields_visualizations: false,
    add_attachment_in_any_status:               false,


    # TO BE REMOVED:
    allow_set_alert:                    false,  # Allows forms to use alerts (notifications to users/self)
    has_extension:                      true,   # Allows forms to request extensions
    has_verification:                   true,   # Allows forms to be verified (additional step)

    # Customizable features
    attach_pdf_in_message:              true,   # Allows option to attach PDF version of the source of Input for email notfication fired by Messages
    global_admin_default:               true,   # Default value to use for admin parameter when calling has_access in user.rb
    sms_im_visibility:                  true,   # Default visibility of SMS IM --> ON
    safety_promotion_visibility:        false,  # Default visibility of Safety Promotion --> OFF

  }

  DOCUMENT_CATEGORIES = ["ProSafeT Information", "General Information", "Safety Reporting Guides Information", "Safety Assurance Guides Information", "SRA(SRM) Guides Information", "SMS IM Guides Information", "Other"]

  LABELS = {

  }

  LAUNCH_OBJECTS = {
    records: ['Sra', 'Investigation'],
    reports: ['Sra', 'Investigation'],
    audits: ['Sra'],
    inspections: ['Sra'],
    evaluations: ['Sra'],
    investigations: ['Sra'],
  }

  OBJECT_NAME_MAP = {
    'Sra'       => 'SRA',
    'SmsAction' => 'Corrective Action',
    'Record'    => 'Report',
    'Report'    => 'Event'
  }

  CAUSE_LABEL = 'Causes'

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
    mobile_mobile_access.map{ |module_key| hierarchy[module_key][:display_name] }
  end

  FAA_INFO = {
    'CHDO'                           => 'CHDO Not Initialized',
    'Region'                         => 'Region Not Initialized',
    'ASAP MOU Holder Name'           => 'Holder Name Not Initialized',
    'ASAP MOU Holder FAA Designator' => 'Holder FAA Designator Not Initialized'
  }

  REPORT_TYPES = {
    "ASAP" => "asap",
    "Non-ASAP" => "non-asap",
  }

  EMPLOYEE_GROUPS = {
    "Flight Crew" => "flight-crew",
    "Inflight" => "inflight",
    "Ground" => "ground",
    "Dispatch" => "dispatch",
    "Maintenance" => "maintenance",
    "General" => "general",
    "Other" => "other",
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

  # To access Safety Promotion Configs use the constant defined below (use CONFIG.sp in code)
  def self.sp
    Object.const_get("#{AIRLINE_CODE}SafetyPromotionConfig") rescue DefaultSafetyPromotionConfig
  end

  # To access Mobile Configs use the constant defined below (use CONFIG.mobile)
  def self.mobile
    Object.const_get("#{AIRLINE_CODE}MobileConfig") rescue DefaultMobileConfig
  end

  # To access SSO Configs use the constant defined below (use CONFIG.sso)
  def self.sso
    Object.const_get("#{AIRLINE_CODE}SsoConfig") rescue DefaultSsoConfig
  end


  def self.custom_options
    Rails.application.config.custom_options
    #CustomOption.all.map{|x| [x.title, (x.options.split(';') rescue [''])]}.to_h
  end


  def self.custom_options_arr
    Rails.application.config.custom_options_arr
  end


  def self.custom_options_by_id
    Rails.application.config.custom_options_arr.map{|x| [x.id, x]}.to_h
  end


  def self.hierarchy
    {
      'ASAP'    => self.sr::HIERARCHY,
      'SMS IM'  => self.im::HIERARCHY,
      'SMS'     => self.sa::HIERARCHY,
      'SRM'     => self.srm::HIERARCHY,
      'SP'      => self.sp::HIERARCHY
    }
  end

  def self.object
    hierarchy.reduce({}){ |acc, (mod,data)| acc.merge(data[:objects]) }
  end

  def self.check_action(user,action,obj,**op)
    self.object[obj.class.name][:actions][action][:access].call(owner:obj,user:user,**op)
  end

  ###################################
  ###        CISP MAPPING         ###
  ###################################
  CISP_TITLE_PARSE = {
    'Flight Crew ASAP'   => 'flightcrew',
  }

  CISP_FIELD_PARSE = {
    'Flight Crew ASAP' => {
      'Flight Information' => {
        'flightNumber'  => 'Flight Number',
        'departure'     => 'Departure Airport',
        'arrival'       => 'Landing Airport',
        'aircraftType'  => 'Aircraft Type',
        'flightPhase'   => 'Flight Phase at Start of Event'
      },
      'Narratives' => { # THIS IS THE FFT CONFIG
        'eventDescription' => "Please provide a narrative about the event, including what happened, where and when the event occurred, and who was involved",
      }
    }
  }

  CISP_TIMEZONES = {"UTC" => "UTC","AST" => "Atlantic Time (Canada)","ADT" => "Atlantic Time (Canada)","AKDT" => "Alaska","AKST" => "Alaska","CST" => "Central Time (US & Canada)","CDT" => "Central Time (US & Canada)","EST" => "Eastern Time (US & Canada)","EDT" => "Eastern Time (US & Canada)","EGST" => "Azores","EGT" => "Azores","HST" => "Hawaii","HAST" => "Hawaii","HADT" => "Hawaii","MST" => "Mountain Time (US & Canada)","MDT" => "Mountain Time (US & Canada)","NST" => "Newfoundland","NDT" => "Newfoundland","PST" => "Pacific Time (US & Canada)","PDT" => "Pacific Time (US & Canada)","PMST" => "Greenland","PMDT" => "Greenland","SST" => "Samoa","WST" => "Greenland","WGT" => "Greenland","WGST" => "Greenland"}

  ###################################
  ### DEFAULT RISK MATRIX CONFIGS ###
  ###################################

  RISK_MATRIX = {
    :likelihood       => ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
    :severity         => (0..4).to_a.reverse,
    :risk_factor      => {"Green - Acceptable" => "lime", "Yellow - Acceptable with mitigation" => "yellow", "Orange - Unacceptable" => "orange"},
  }

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
      direction: :up,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      row_header_name: 'SEVERITY',
      row_header: ['4', '3', '2', '1', '0'],
      column_header_name: 'CLASS',
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
      0 => "4",
      1 => "3",
      2 => "2",
      3 => "1",
      4 => "0",
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
      row_header: [''],
      column_header_name: 'PROBABILITY',
      column_header: ['A - Improbable','B - Unlikely','C - Remote','D - Probable','E - Frequent'],
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
      severity_pos: 'row',
      likelihood_pos: 'column',

      row_header_name: 'SEVERITY',
      row_header: ['4', '3', '2', '1', '0'],
      column_header_name: 'PROBABILITY',
      column_header: ['A - Improbable','B - Unlikely','C - Remote','D - Probable','E - Frequent'],

      rows_color: [
        ['yellow',      'yellow',       'orange',       'orange',       'orange' ],
        ['yellow',      'yellow',       'yellow',       'orange',       'orange' ],
        ['limegreen',   'limegreen',    'yellow',       'yellow',       'orange' ],
        ['limegreen',   'limegreen',    'limegreen',    'limegreen',    'limegreen'],
        ['limegreen',   'limegreen',    'limegreen',    'limegreen',    'limegreen']
      ],
    },

    risk_definitions: {
      limegreen:   { rating: 'Green - Acceptable'                   },
      yellow:      { rating: 'Yellow - Acceptable with mitigation'  },
      orange:      { rating: 'Orange - Unacceptable'                },
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
    self::MATRIX_INFO[:severity_table_dict][severity_score] if severity_score.present?
  end

  def self.print_probability(owner, probability_score)
    self::MATRIX_INFO[:probability_table_dict][probability_score] if probability_score.present?
  end

  def self.print_risk(probability_score, severity_score)
    if probability_score.present? && severity_score.present?
      lookup_table = MATRIX_INFO[:risk_table][:rows]
      return MATRIX_INFO[:risk_table_index][lookup_table[probability_score][severity_score].to_sym] rescue nil
    end
  end

end
