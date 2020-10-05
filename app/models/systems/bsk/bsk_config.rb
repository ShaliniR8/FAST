class BSKConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Miami Air International',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:               true,
    drop_down_risk_selection:     true,

    # TO BE REMOVED
    base_risk_matrix:             false,
    has_verification:             true,
    hazard_root_cause_lock:       true

  })

    # SMS IM Module

  MATRIX_INFO = DefaultConfig::MATRIX_INFO.deep_merge({
    risk_table: {
      column_header_name: 'LIKELIHOOD',
    },
  })


  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                            => 'ACE-FSDO-09',
    'Region'                          => 'Eastern',
    'ASAP MOU Holder Name'            => 'Miami Air International',
    'ASAP MOU Holder FAA Designator'  => 'N/A'
  })

end
