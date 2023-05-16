class ZEROGConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = ['ASAP', 'SMS']


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'ZERO G',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:               true,
    drop_down_risk_selection:     true,
    asrs_integration:             true,

    # Customizable features
    safety_promotion_visibility:  true,

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

end
