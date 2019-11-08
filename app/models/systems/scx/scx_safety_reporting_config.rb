class SCXSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:      false,
    # Airline-Specific Features:
  })

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Submission' => {
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
