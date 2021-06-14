class EULENSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # Flag for corrective action and root causes at submission level
    submission_corrective_action_root_cause:    true
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Submission' => {
        fields: {
          # occurrences: {default: true, title: (Submission.find_top_level_section.label rescue nil)},
          occurrences_full: {default: true,
            visible: 'query',
            title: "Full #{Submission.find_top_level_section.label rescue nil}"},
        },
        panels: %i[causes occurrences].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc }
      }
    }
  })

end
