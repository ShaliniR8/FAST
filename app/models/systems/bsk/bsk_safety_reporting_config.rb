class BSKSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    template_nested_fields:             true,
    # Airline-Specific Features:
    observation_phases_trend:           true,
  })

  OBSERVATION_PHASES = [
    "Observation Phase",
    "Condition",
    "Threat", "Sub Threat",
    "Error", "Sub Error",
    "Human Factor", "Comment"
  ]

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects: {
      'CorrectiveAction' => {
          fields: {
            recommendation: { visible: '' },
            company: { visible: '' },
            employee: { visible: '' }
          }
      }
    },
    menu_items: {
      'Reports' => {
        title: 'Reports', path: 'records_path(status: "All")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Record'), user, 'index', true, true)}
      },
      'Events' => {
        title: 'Events',  path: '#',
        display: proc{|user:,**op|
          priv_check.call(Object.const_get('Report'), user, 'index', true, true)
        },
        subMenu: [
          {title: 'All', path: 'reports_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Report'), user, 'index', true, true)}},
          {title: 'Summary', path: 'summary_reports_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Report'), user, 'admin', true, true) && CONFIG.sr::GENERAL[:event_summary]}},
          {title: 'Tabulation', path: 'tabulation_reports_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Report'), user, 'admin', true, true) && CONFIG.sr::GENERAL[:event_tabulation]}},
        ]
      },
    }

  })

end
