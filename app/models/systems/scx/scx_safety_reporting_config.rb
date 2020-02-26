class SCXSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:      false,
    enable_dual_report:       false,
    # Airline-Specific Features:
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Submission' => {
        fields: {
          submitter: { default: true, visible: "admin#{GENERAL[:show_submitter_name] ? ',index,show' : ''}" },
        },
        actions: {
          pdf: {
            access: proc { |owner:,user:,**op|
              # Requested only admins can use normal pdf function 11/8/2019 by Stephanie Gabert
              super_proc('Submission',:pdf).call(owner:owner,user:user,**op) && user.admin?
            },
          },
        },
      },
      'Record' => {
        fields: {
          submitter: { default: true, visible: "admin#{GENERAL[:show_submitter_name] ? ',index,show' : ''}" },
        },
        actions: {
          pdf: {
            access: proc { |owner:,user:,**op|
              # Requested only admins can use normal pdf function 11/8/2019 by Stephanie Gabert
              super_proc('Record',:pdf).call(owner:owner,user:user,**op) && user.admin?
            },
          },
        },
      },
      'Report' => {
        actions: {
          pdf: {
            access: proc { |owner:,user:,**op|
              # Requested only admins can use normal pdf function 11/8/2019 by Stephanie Gabert
              super_proc('Report',:pdf).call(owner:owner,user:user,**op) && user.admin?
            },
          },
          meeting_ready: {
            access: proc { |owner:,user:,**op|
              # Requested unavailable until root cause analysis 10/2019 by Stephanie Gabert
              super_proc('Report',:pdf).call(owner:owner,user:user,**op) && owner.root_causes.present?
            },
          },
          close: {
            access: proc { |owner:,user:,**op|
              # Requested unavailable until root cause analysis 10/2019 by Stephanie Gabert
              super_proc('Report',:pdf).call(owner:owner,user:user,**op) && owner.root_causes.present?
            },
          },
        },
      },
    },
  })

end
