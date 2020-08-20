class RVFSafetyRiskManagementConfig < DefaultSafetyRiskManagementConfig

  HIERARCHY = DefaultSafetyRiskManagementConfig::HIERARCHY.deep_merge({
    objects: {

      # 'Sra' => {
      #   fields: {
      #     system_task: { visible: '' },
      #     reviewer: { visible: '' },
      #     approver: { visible: '' },
      #     due_date: { visible: ''},

      #     manuals_panel_start: { visible: '' },
      #     manuals: { visible: '' },
      #     other_manual: { visible: '' },
      #     manuals_comment: { visible: '' },
      #     manuals_panel_end: { visible: '' },

      #     regulatory_compliances_panel_start: { visible: '' },
      #     compliances: { visible: '' },
      #     other_compliance: { visible: '' },
      #     compliances_comment: { visible: '' },
      #     regulatory_compliances_panel_end: { visible: '' },

      #     departments_comment: { visible: '' },
      #     programs_comment: { visible: '' }
      #   }
      # },

      # 'Hazard' => {
      #   fields: {
      #     responsible_user: { title: 'Lead Analyst' },
      #     approver: { title: 'Risk Acceptor' },
      #     due_date: { title: 'Date to Validate Effectiveness'},
      #     departments: { required: true },
      #     description: { required: true }
      #   }
      # },

      # 'RiskControl' => {
      #   fields: {
      #     approver: { title: 'Lead Analyst' },
      #     control_type: { visible: '' },
      #     notes: { visible: '' }
      #   }
      # }
    }
  })

end
