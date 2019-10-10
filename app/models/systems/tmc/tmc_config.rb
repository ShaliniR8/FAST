class TMCConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                               'Travel Management Company',
    time_zone:                          'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS

    # SYSTEM-WIDE FORM CONFIGS
    allow_reopen_forms:                false,
    has_root_causes:                   false,

  })


  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'=>'ACE-FSDO-09',
    'Region'=>'Central',
    'ASAP MOU Holder Name'=>'Travel Management Company',
    'ASAP MOU Holder FAA Designator'=>'TMC'
  })


  # calculate_probability used .last instead of .min on the return

end
