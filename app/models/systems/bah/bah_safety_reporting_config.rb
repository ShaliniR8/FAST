class BAHSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    submission_local_time_zone:       true
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects: {
      'CorrectiveAction' => {
        fields: {
          employee: {
            visible: ''
          },
          company: {
            visible: ''
          },
          bimmediate_action: {
            visible: ''
          },
          bcomprehensive_action: {
            visible: ''
          },
          description: {
            visible: ''
          }
        }
      }
    },
    menu_items: {
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| false}
      },
    }
  })

end
