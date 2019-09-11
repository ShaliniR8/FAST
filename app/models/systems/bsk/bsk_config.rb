class BSKConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP]


  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    version:                      '1.0.3',
    name:                         'Miami Air International',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS
    has_mobile_app:               true,

    # TO BE REMOVED
    has_verification:             true,
  })

    # SMS IM Module

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                            => 'ACE-FSDO-09',
    'Region'                          => 'Eastern',
    'ASAP MOU Holder Name'            => 'Miami Air International',
    'ASAP MOU Holder FAA Designator'  => 'N/A'
  })

end
