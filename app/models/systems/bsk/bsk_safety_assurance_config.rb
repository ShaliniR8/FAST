class BSKSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:            '3',
  })


  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects: {
      'Audit' => {
        fields: {
          vendor: { visible: '' },
          process: { visible: '' },
          reference: { visible: '' },
          supplier: { visible: '' }
        }
      },

      'Finding' => {
        fields: {
          authority: { visible: '' },
          controls: { visible: '' },
          interfaces: { visible: '' },
          policy: { visible: '' },
          procedures: { visible: '' },
          process_measures: { visible: '' },
          responsibility: { visible: '' },
          action_taken: { visible: '' },
          analysis_result: { visible: '' },
          other: { visible: '' }
        }
      },

      'SmsAction' => {
        fields: {
          emp: { visible: '' },
          dep: { visible: '' },
          immediate_action: { visible: '' },
          immediate_action_comment: { visible: '' },
          comprehensive_action: { visible: '' },
          comprehensive_action_comment: { visible: '' },
          action_taken: { visible: '' }
        }
      }
    },
    menu_items: {
      'Audits' => {
        title: 'Audits', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Audit'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'audits_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Audit'), user, 'index', true, true)}},
          {title: 'New', path: 'new_audit_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Audit'), user, 'new', true, true)}},
          {title: 'Recurring Audits', path: "recurrences_path(form_type: 'Audit')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] && priv_check.call(Object.const_get('Audit'), user, 'admin', true, true)}},
          {title: 'New Recurring Audits', path: "new_recurrence_path(form_type: 'Audit')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] && priv_check.call(Object.const_get('Audit'), user, 'admin', true, true)}},
        ]
      },
      'Inspections' => {
        title: 'Inspections', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Inspection'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'inspections_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Inspection'), user, 'index', true, true)}},
          {title: 'New', path: 'new_inspection_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Inspection'), user, 'new', true, true)}},
          {title: 'Recurring Inspections', path: "recurrences_path(form_type: 'Inspection')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] && priv_check.call(Object.const_get('Inspection'), user, 'admin', true, true)}},
          {title: 'New Recurring Inspections', path: "new_recurrence_path(form_type: 'Inspection')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] && priv_check.call(Object.const_get('Inspection'), user, 'admin', true, true)}},
        ]
      },
      'Evaluations' => {
        title: 'Evaluations', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Evaluation'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'evaluations_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Evaluation'), user, 'index', true, true)}},
          {title: 'New', path: 'new_evaluation_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Evaluation'), user, 'new', true, true)}},
          {title: 'Recurring Inspections', path: "recurrences_path(form_type: 'Evaluation')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] && priv_check.call(Object.const_get('Evaluation'), user, 'admin', true, true)}},
          {title: 'New Recurring Inspections', path: "new_recurrence_path(form_type: 'Evaluation')",
            display: proc{|user:,**op| CONFIG.sa::GENERAL[:enable_recurrence] && priv_check.call(Object.const_get('Evaluation'), user, 'admin', true, true)}},
        ]
      },
      'Investigations' => {
        title: 'Investigations', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'investigations_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'index', true, true)}},
          {title: 'New', path: 'new_investigation_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'new', true, true)}},
        ]
      },
      'Findings' => {
        title: 'Findings', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'findings_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', true, true)}},
          {title: 'For Audits', path: 'findings_path(:type=>"Audit")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Audit'), user, 'index', true, true)}},
          {title: 'For Inspections', path: 'findings_path(:type=>"Inspection")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Inspection'), user, 'index', true, true)}},
          {title: 'For Evaluations', path: 'findings_path(:type=>"Evaluation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Evaluation'), user, 'index', true, true)}},
          {title: 'For Investigations', path: 'findings_path(:type=>"Investigation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'index', true, true)}},
        ]
      },
      'Corrective Actions' => {
        title: 'Corrective Actions', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'sms_actions_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'index', true, true)}},
          {title: 'For Findings', path: 'sms_actions_path(:type=>"Finding")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', true, true)}},
          {title: 'For Investigations', path: 'sms_actions_path(:type=>"Investigation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'index', true, true)}},
          {title: 'New', path: 'new_sms_action_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'new', true, true)}},
        ]
      },
      'Recommendations' => {
        title: 'Recommendations', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Recommendation'), user, 'index', true, true)},
        subMenu: [
          {title: 'All', path: 'recommendations_path(status: "All")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SmsAction'), user, 'index', true, true)}},
          {title: 'For Findings', path: 'recommendations_path(:type=>"Finding")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', true, true)}},
          {title: 'For Investigations', path: 'recommendations_path(:type=>"Investigation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Investigation'), user, 'index', true, true)}},
        ]
      },
    }
  })
end
