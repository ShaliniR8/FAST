class TemplateConfig < DefaultConfig

  # Used for linking databases in database.yml; example would be %w[audit]
  ENABLED_SYSTEMS = %w[]
  # Used for creating different environments in database.yml; example would be %w[training]
  SYSTEM_ENVIRONMENTS = %w[]

  GENERAL = DefaultConfig::GENERAL.merge({
    # AIRLINE-SPECIFIC CONFIGS

    # SYSTEM CONFIGS

    # SYSTEM-WIDE FORM CONFIGS

  })

  FAA_INFO = DefaultConfig::FAA_INFO.merge({

  })

end
