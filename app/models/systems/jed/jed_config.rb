class JEDConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'King Abdulaziz International Airport',
    time_zone:                    'Riyadh',

    # SYSTEM CONFIGS
    has_mobile_app:               false,
    drop_down_risk_selection:     true,

    # TO BE REMOVED
    base_risk_matrix:             true,
    has_verification:             true,
    hazard_root_cause_lock:       true
  })
end
