class SacramentoConfig < DefaultConfig

  # Used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  # Used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = ['ASAP']

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Sacramento International Airport',
    sms_im_visibility:            false,
    safety_promotion_visibility:  true,
    has_gmap:                     true,
    gis_layers:                   true,
    lat:                          38.6953,
    lng:                          -121.5896,
    external_link:                false,
    enable_sso:                   false,
    login_option:                 'login'
  })

  EMPLOYEE_GROUPS = {
    "Airside"   => "airside",
    "Landside"  => "landside",
    "Terminal"  => "terminal",
    "Other"     => "other"
  }

  REPORT_TYPES = {
    
  }

  EXTERNAL_LINK =
    if Rails.env.production?
      'https://sca.prodigiq.com'
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
    response = conn.post('/api/sba/users/sync') do |req|
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
    :likelihood       => ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
    :severity         => (0..4).to_a.reverse,
    :risk_factor      => {"LOW" => "lime", "MODERATE" => "yellow", "HIGH" => "orange"},
  }

  MATRIX_INFO = DefaultConfig::MATRIX_INFO.deep_merge({

    severity_table: {
      row_header:['5 - Catastrophic','4 - Hazardous','3 - Major','2 - Minor', '1 - Negligible'],
      column_header_name: 'SEVERITY DEFINITIONS',
      column_header: ['Life Safety', 'Airport Operations', 'Environmental', 'Public Perception/Reputation'],
      rows: [
        [ # Life Safety
          "<ul> <li>Injury/Illness extensive persons</li> <li>Many casualties</li> </ul>",
          "<ul> <li>Injury/Illness many persons</li> <li>Casualties</li> </ul>",
          "<ul> <li>Injury/Illness few persons</li> <li>Casualty</li> </ul>",
          "<ul> <li>First Aid required Injury/Illness</li> <li>No Casualty</li> </ul>",
          "<ul> <li>No first aid required injury/illness</li> <li>No casualty</li> </ul>"
        ],
        [ # Airport Operations
          "<ul> <li> Loss of total operation 3+ hours </li> <li> Loss of partial operations greater than 60+ days </li> </ul>",
          "<ul> <li> Loss of total operation 1 to 3 hours </li> <li> Partial loss of operation 20 to 59 days </li> </ul>",
          "<ul> <li> Loss of total operations less than 1 hour </li> <li> Loss of partial operations less than 20 days </li> </ul>",
          "<ul> <li> Very limited partial operational impact </li> <li> 2 to 4 hours </li> </ul>",
          "<ul> <li> None to minimal operational impact </li> <li> Less than 2 hours </li> </ul>"
        ],
        [
          #Environmental
          "<ul> <li> Non-contained, long term impact 90 + days </li> </ul>",
          "<ul> <li> Non-contained, resulting in environmental impact 30 to 89 days </li> </ul>",
          "<ul> <li> Non-contained but manageable  </li> <li> Mitigated in less than 30 days </li> </ul>",
          "<ul> <li> Contained with none to limited impact </li> </ul>",
          "<ul> <li> No environmental impact </li> </ul>"
        ],
        [
          # Public Perception/Reputation
          "<ul> <li> Sustained local media (anniversary coverage) and broad global media exposure </li> </ul>",
          "<ul> <li> Public exposure by regional media, national and global exposure greater than    1 week </li> </ul>",
          "<ul> <li> Public exposure by local and national media between 24 to 72 hrs. </li> </ul>",
          "<ul> <li> Limited exposure to public  </li> <li> Blog/tweet/local news less than 24 hours </li> </ul>",
          "<ul> <li> Perception unchanged  </li> <li> No public reporting </li> </ul>",
        ]
      ].transpose
    },

    severity_table_dict: {
      0 => '0 - Negligible',
      1 => '1 - Minor',
      2 => '2 - Major',
      3 => '3 - Hazardous',
      4 => '4 - Catastrophic'
    },

    probability_table: {
      title: 'PROBABILITY DEFINITIONS',
      column_header: ['A', 'B', 'C', 'D', 'E'],
      row_header: ["",""],
      rows: [
        [
          'EXTREMELY IMPROBABLE', 
          'EXTREMEMLY REMOTE', 
          'REMOTE', 
          'PROBABLE', 
          'FREQUENT'
        ],
        [
          "<ul> <li> Almost impossible </li> <li> Possibly only once in 100+ years </li> </ul>",
          "<ul> <li> Conceivable but highly unlikely </li> <li> Possibly once every 50+ years </li> </ul>",
          "<ul> <li>  Unlikely but possible to occur </li> <li> Possibly once every 5+ years </li> </ul>",
          "<ul> <li>  Regularly expected to occur in the system </li> <li> Likely to occur multiple times per year or once per month </li> </ul>",
          "<ul> <li>  Continuously expected to occur in the system </li> <li> Likely to occur once a day or multiple times per week </li> </ul>",
        ]
      ]
    },

    probability_table_dict: {
      1 => 'A - EXTREMELY IMPROBABLE',
      2 => 'B - EXTREMEMLY REMOTE',
      3 => 'C - REMOTE',
      4 => 'D - PROBABLE',
      5 => 'E - FREQUENT',
    },

    risk_table: {
      title: 'RISK ASSESSMENT MATRIX',
      column_header_name: "Probability <br/> <i><small>✱Note: Unacceptable level of risk unless mitigated.</small></i>",
      row_header: ['5 - Catastrophic','4 - Hazardous','3 - Major','2 - Minor', '1 - Negligible'],
      column_header: ['A - EXTREMELY IMPROBABLE', 'B - EXTREMEMLY REMOTE', 'C - REMOTE', 'D - PROBABLE', 'E - FREQUENT'],

      rows: [
        ['✱', '', '', '', ''],
        ['', '', '', '', ''],
        ['', '', '', '', ''],
        ['', '', '', '', ''],
        ['', '', '', '', '']
      ],

      rows_color: [
        ["orange", "red", "red", "red", "red"],
        ["yellow", "orange", "orange", "red", "red"],
        ["yellow", "yellow", "orange", "orange", "red"],
        ["limegreen", "limegreen", "yellow", "yellow", "yellow"],
        ["limegreen", "limegreen", "limegreen", "limegreen", "yellow"]
      ]
    },

    risk_definitions: {
      red: {rating: "Extreme Risk", description: "Mitigation/s must be implemented.\nAccountable Executive has final approval Authority."},
      orange: {rating: "High Risk", description: "Mitigation/s must be implemented. \nResponsible Executive (RE) has approval Authority. "},
      yellow: {rating: "Medium Risk", description: "Mitigations may be implemented. \nSMS Manager has approval Authority with concurrence by another ASR member or the RE. "},
      limegreen: {rating: "Low Risk", description: "Acceptable but may be mitigated. \nSMS Manager has approval authority with concurrence by another ASR member or the RE."}
    },

    risk_table_index: {
      'Extreme Risk'  => 'red',
      'High Risk'     =>  'orange',
      'Medium Risk'   =>  'yellow',
      'Low Risk'      =>  'limegreen'
    },

    risk_table_dict: {
      limegreen:  'Low Risk',
      orange: 'High Risk',
      yellow: 'Medium Risk',
      red:    'Extreme Risk'
    }

  })

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                           => 'ProSafeT',
    'Region'                         => 'Pacific',
    'ASAP MOU Holder Name'           => 'ProSafeT',
    'ASAP MOU Holder FAA Designator' => 'ProSafeT'
  })


  # SABRE INTEGRATION
  SABRE_MAPPABLE_FIELD_OPTIONS = {
    "Flight Date"        => "flight_date",
    "Flight Number"      => "flight_number",
    "Tail Number"        => "tail_number",
    "Departure Airport"  => "departure_airport",
    "Arrival Airport"    => "arrival_airport",
    "Landing Airport"    => "landing_airport",
    "Captain"            => "ca",
    "First Officer"      => "fo",
    "Flight Attendant 1" => "fa_1",
    "Flight Attendant 2" => "fa_2"
  }

end
