class EULENSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:

    # Airline-Specific Features:
    submission_corrective_action_root_cause:    true
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge( {
    objects: {

      'Submission' => {
        fields: {
          # occurrences: {default: true, title: (Submission.find_top_level_section.label rescue nil)},
          occurrences_full: {default: true,
            visible: 'query',
            title: "Full #{Submission.find_top_level_section.label rescue nil}"},
        },
        panels: %i[causes occurrences].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
    },
    menu_items: {
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| false},
        subMenu: [
          {title: 'All', path: 'faa_reports_path',
            display: proc{|user:,**op| true}},
          {title: 'New', path: 'new_faa_report_path',
            display: proc{|user:,**op| true}},
        ]
      },
    }
  })
end
