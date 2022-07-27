class DemoSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  GENERAL = DefaultSafetyRiskManagementConfig::GENERAL.merge({
    risk_assess_sras:      true,
    add_reports_to_sra:    true,
    enable_risk_register:  true
  })

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects: {
      'RiskControl' => {
        fields: {
          risk_category: {
            field: 'risk_category', title: 'Risk Category',
            num_cols: 6, type: 'select', visible: 'form,show',
            required: false, options: "CONFIG.custom_options['Risk Categories']"
          }
        }
      }
    },
    menu_items: {
      'Hazards' => {
        title: 'Hazards', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Hazard'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'hazards_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Hazard'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_hazard_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Hazard'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      }
    }
  })

end
