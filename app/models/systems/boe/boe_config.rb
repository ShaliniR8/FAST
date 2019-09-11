class BOEConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    version:                         '1.0.3',
    name:                            'Boeing Executive Flight Operations',
    time_zone:                       'Central Time (US & Canada)',

    # SYSTEM CONFIGS
    base_risk_matrix:                false,
    has_root_causes:                 false,

    # SYSTEM-WIDE FORM CONFIGS

  })


  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'=>'ACE-FSDO-09',
    'Region'=>'Central',
    'ASAP MOU Holder Name'=>'Boeing',
    'ASAP MOU Holder FAA Designator'=>'BASE'
  })

  #BOE's Risk Matrix is used as the default, therefore you will find it defined in default_config.rb

end
