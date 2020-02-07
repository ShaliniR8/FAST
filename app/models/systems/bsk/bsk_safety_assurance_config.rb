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
    }
  })
end
