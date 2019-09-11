class WAAConfig < DefaultConfig

  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    version:                            '1.2.0',
    name:                               'World Atlantic Airlines',
    time_zone:                          'Central Time (US & Canada)',

    # SYSTEM CONFIGS

    # SYSTEM-WIDE FORM CONFIGS
    has_root_causes:                    false,

  })


  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    "CHDO" => "FAA Flight Standards District Office, 300W 36th Ave, Suite 101, Anchorage, AK, 99503",
    "Region" => "Anchorage",
    "ASAP MOU Holder Name" => "N/A",
    "ASAP MOU Holder FAA Designator" => "N/A"
  })


end
