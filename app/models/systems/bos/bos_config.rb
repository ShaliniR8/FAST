class BOSConfig < DefaultConfig
  #used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  #used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = %w[ASAP SMS]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'Boston Logan International Airport',
    time_zone:                    'Eastern Time (US & Canada)',

    # SYSTEM CONFIGS    
    has_gmap:                      true,
    gis_layers:                    true,

    lat:                           42.363783,
    lng:                           -71.010203,
    gMapZoom:                      14,

    global_admin_default:          false,
  })

end
