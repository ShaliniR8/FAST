class BSKSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({


  })


  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects:{
      'Sra' => {
        fields: {
          system_task: { visible: '' },
          reviewer: { visible: '' }
        }
      },

      'Hazard' => {
        actions: {
          complete: {
            access: proc { |owner:,user:,**op|
              # Request for Hazards to not be completed without root cause analysis - 11/2019 Armando Martinez
              super_proc('Hazard',:complete).call(owner:owner,user:user,**op) && owner.occurrences.present?
            },
          },
        },
      },
    },
  })
end
