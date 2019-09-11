class DefaultSafetyReportingConfig
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them or copy the template configs
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:
    enable_orm:               false,     # Enables ORM Reports - default off
    show_submitter_name:      true,      # Displays submitter names when access to show (admins will always see it)- default on
    submission_description:   true,      # Changes Character Limit or adds General Description - default on
    template_nested_fields:   false,     # WIP nested smart forms functionality - default off

    # Airline-Specific Features:
    observation_phases_trend: false,     # Specific Feature for BSK - default off
    event_summary:            false,     # Adds summary Tab for Events in Safety Reporting nav bar - default off
    event_tabulation:         false,     # Adds Tabulation Tab for Events in Safety Reporting nav bar - default off
  }

  OBSERVATION_PHASES = [
    'Observation Phase',
    'Condition',
    'Threat', 'Sub Threat',
    'Error', 'Sub Error',
    'Human Factor', 'Comment'
  ]

  HIERARCHY = {
    display_name: 'ASAP',
    objects: {
      'Submission' => 'Submission',
      'Record' => 'Report',
      'Report' => 'Event',
      'CorrectiveAction' => 'Corrective Action',
    }
  }

end
