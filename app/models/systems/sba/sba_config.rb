class SBAConfig < DefaultConfig
  
  ENABLED_SYSTEMS = %w[]
  # For creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  # For selecting which modules are available to mobile; example would be %w[ASAP]
  MOBILE_MODULES = %w[ASAP]

  #############################
  ### GLOBAL CONFIGURATIONS ###
  #############################

  GENERAL = DefaultConfig::GENERAL.merge({
    name:                         "City of Santa Barbara",
    sms_im_visibility:            false,
    safety_promotion_visibility:  true,
    has_gmap:                     true,
    gis_layers:                   true,
    lat:                          34.422331644,
    lng:                          -119.83749665,
    gMapZoom:                     14,
    external_link:                true,
    enable_sso:                   true,
    login_option:                 'sso',
  })

  LAUNCH_OBJECTS = DefaultConfig::LAUNCH_OBJECTS.deep_merge({
    records: ['Sra'],
    reports: ['Sra']
  })

  ###################################
  ### DEFAULT RISK MATRIX CONFIGS ###
  ###################################

  EMPLOYEE_GROUPS = {
    "Ground" => "ground",
    "General" => "general",
    "Other" => "other",
  }

  REPORT_TYPES = {}

  EXTERNAL_LINK =
    if Rails.env.production?
      'https://sba.prodigiq.com'
    else
      'http://192.168.254.64:3001'
    end

  def self.sync_user(user, prev_email)
    conn = Faraday.new(
      url: "#{CONFIG::EXTERNAL_LINK}",
      params: {
      email: [prev_email || user.email, user.email],
      username: user.username,
      first_name: user.first_name,
      last_name: user.last_name,
      level: user.level,
      disable: user.disable
    },
      headers: {'Content-Type' => 'application/json'}
    )
    response = conn.post('/api/jed/users/sync') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Client-ID'] = 'gr9CyN5iFjzzED9oFa9YZwMXsvc1T90c70LY3FOnnjM'
      req.headers['Client-Secret'] = 'cgNKSy15bzoJbEr3TVA2ZcItOsuOAJ82fDSj6mbN7xw'
    end
    response
  end
  
  def self.external_link(user)
    res = Faraday.post("#{CONFIG::EXTERNAL_LINK}/api/sba/users/find",
      {email: user.email}.to_json,
        {
          'Content-Type' => 'application/json',
          'Client-ID' => 'gr9CyN5iFjzzED9oFa9YZwMXsvc1T90c70LY3FOnnjM',
          'Client-Secret' => 'cgNKSy15bzoJbEr3TVA2ZcItOsuOAJ82fDSj6mbN7xw'})
    if res.success?
      json = JSON.parse(res.body) rescue nil
      "#{CONFIG::EXTERNAL_LINK}/users/#{json['id']}" if json.present?
    end
  end

  RISK_MATRIX = {
    :likelihood       => ["Frequent (A)", "Probable (B)", "Remote (C)", "Extremely Remote (D)", "Extremely Improbable (E)"],
    :severity         => (1..5).to_a,
    :risk_factor      => {"Low Risk - Acceptable" => "lime", "Moderate Risk - Acceptable with mitigation" => "yellow", "High Risk - Unacceptable" => "red"},
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

      orientation: :horizontal,
      direction: :right,
      size: 'col-xs-6',
      title_style: 'severityTitle',
      main_header_style: 'sevMainHeader',
      header_style: 'sevHeader',
      cell_name: 'severity_td',

      column_header_name: 'SEVERITY',
      column_header: ['Negligible (1)', 'Minor (2)', 'Major (3)', 'Hazardous (4)', 'Catastrophic (5)'],
      row_header_name: 'CLASS',
      row_header: [
        'People (Injury)',
        'Continuity of Operations (Impact)',
        'Environment (Effect)',
        'Assets (Damage)',
        'Perception/Reputation'],
      rows: [
        [ 'No first aid required', 'Injury with first aid', 'Injury with transport', 'Multiple injuries with transport','Fatality'],
        [ 'No impact, recovery time immediate', 'Minor disruption to normal ops, recovery time <2 hour', 'Major disruption to normal ops, recovery time 2-24 hours', 'Severe disruption to normal ops, recovery time 24-48 hour', 'Widespread regional disruption to ops, recovery time indefinite'],
        [ 'No impact, non-reportable', 'Reportable, containable minimal volume of hazardous material (<20gal)', 'Reportable, containable moderate volume of hazardous material (<100gal)', 'Reportable, non-containable moderate volume of hazardous material (<100gal)', 'Reportable, non-containable significant volume of hazardous material (>100gal)'],
        [ 'No repairs required', "<$10K", '$10K - $500K', '$500K - $1M', ">$1M" ],
        [ 'Negligible', 'Negligible', 'Negligible', 'Negligible', 'Negligible']
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

      row_header_name: 'PROBABILITY',
      row_header: ['Frequent (A)', 'Probable (B)', 'Remote (C)', 'Extremely Remote (D)', 'Extremely Improbable (E)'],
      column_header_name: '',
      column_header: ['Frequency'],
      rows: [
        ['Likely to occur once a day or multiple times per week; continuously expected to occur in the system.'],
        ['Likely to occur multiple times per year or once per month; regularly expected to occur in the system.'],
        ['Possibly once a year or multiple times from 1 year to less than 5 years; unlikely but possible to occur.'],
        ['Conceivable but highly unlikely; possibly once in every 5 to less than 10 years.'],
        ['Almost impossible; possibly only once in 10 to 100 years']
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

      row_header_name: 'PROBABILITY',
      row_header: ['Frequent (A)', 'Probable (B)', 'Remote (C)', 'Extremely Remote (D)', 'Extremely Improbable (E)'],
      column_header_name: 'SEVERITY',
      column_header: ['Negligible (1)','Minor (2)','Major (3)','Hazardous (4)','Catastrophic (5)'],

      rows_color: [
        ['limegreen',      'yellow',       'red',       'red',       'red' ],
        ['limegreen',      'yellow',       'yellow',       'red',       'red' ],
        ['limegreen',   'limegreen',    'yellow',       'yellow',       'red' ],
        ['limegreen',   'limegreen',    'limegreen',    'yellow',    'yellow'],
        ['limegreen',   'limegreen',    'limegreen',    'yellow',    'yellow']
      ],
    },

    risk_definitions: {
      limegreen:   { rating: 'Low Risk', description: "Acceptable"  },
      yellow:      { rating: 'Moderate Risk', description: "Acceptable with mitigation"  },
      red:      { rating: 'High Risk', description: "Unacceptable" },
    },

    risk_table_index: {
      'Moderate Risk'  => 'yellow',
      'Low Risk'       => 'limegreen',
      'High Risk'      => 'red',

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
      limegreen:  'Low Risk - Acceptable',
      red:        'High Risk - Unacceptable',
      yellow:        'Moderate Risk - Acceptable with mitigation'
      # orange:        'Orange - Unacceptable',

    }
  }
end
