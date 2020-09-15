class DemoConfig < DefaultConfig

  # Used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[audit]
  # Used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[training]

  MOBILE_MODULES = ['ASAP', 'SMS']

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS
    name:                         'ProSafeT Demo',
    time_zone:                    'Pacific Time (US & Canada)',

    # SYSTEM CONFIGS
    enable_mailer:                false,
    has_mobile_app:               true,
    track_log:                    true,

    # SYSTEM-WIDE FORM CONFIGS
    allow_reopen_report:          false,
    configurable_risk_matrices:   true,
    shared_links:                 true,
    drop_down_risk_selection:     true,

    # TO BE REMOVED:
    allow_set_alert:              true,
    has_extension:                true,
    has_verification:             true,
  })

  FAA_INFO = DefaultConfig::FAA_INFO.merge({
    'CHDO'                           => 'ProSafeT',
    'Region'                         => 'Pacific',
    'ASAP MOU Holder Name'           => 'ProSafeT',
    'ASAP MOU Holder FAA Designator' => 'ProSafeT'
  })

end
