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
    menu_items: {
      'Sra' => {
        title: 'SRA (SRM)', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Sra'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'sras_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Sra'), user, 'index', true, true)}},
          {title: 'New', path: 'new_sra_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Sra'), user, 'new', true, true)}},
        ]
      },
      'Hazards' => {
        title: 'Hazards', path: 'hazards_path(status: "All")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Hazard'), user, 'index', true, true)},
      },
      'Risk Controls' => {
        title: 'Risk Controls', path: 'risk_controls_path(status: "All")',
        display: proc{|user:,**op| priv_check.call(Object.const_get('RiskControl'), user, 'index', true, true)},
      },
      'Safety Plans' => {
        title: 'Safety Plans', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('SafetyPlan'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'safety_plans_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SafetyPlan'), user, 'index', true, true)}},
          {title: 'New', path: 'new_safety_plan_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SafetyPlan'), user, 'new', true, true)}},
        ]
      },
    }
  })
end
