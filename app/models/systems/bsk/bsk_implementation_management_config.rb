class BSKImplementationManagementConfig < DefaultImplementationManagementConfig

  GENERAL = DefaultImplementationManagementConfig::GENERAL.merge({

    # Airline-Specific Features:
    has_framework:              true,

  })

end
