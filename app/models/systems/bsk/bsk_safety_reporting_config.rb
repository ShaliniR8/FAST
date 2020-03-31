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
          employee: { visible: '' },
          faa_approval: {
            field: 'faa_approval', title: 'Requires FAA Approval',
            num_cols: 12,  type: 'boolean_box', visible: 'index,form,show',
          },
        },
        panels: {
          occurrences: {
            partial: '/occurrences/occurrences_panel',
            visible: proc { |owner:,user:,**op| false },
            show_btns: proc { |owner:,user:,**op| !['Pending Approval', 'Completed'].include? owner.status },
            data: proc { |owner:,user:,**op| { owner: owner } },
          },
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
      'Corrective Actions' => {
        title: 'Corrective Actions', path: 'corrective_actions_path(status: "All")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('CorrectiveAction'), user, 'index', true, true)}
      },
    }

  })

end
