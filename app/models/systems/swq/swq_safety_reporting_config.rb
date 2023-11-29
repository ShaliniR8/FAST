class SWQSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    enable_orm:                  true,
    submission_corrective_action_root_cause:    false,
    enable_external_email:     false,
    show_pdf_column_scoreboard: true,
  })
  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects:{
      'Report' => {
        actions: [
          #INLINE
          *%i[task],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[causes occurrences sras investigations tasks].reduce({}) { |acc,panel| acc[panel] = DICTIONARY::PANEL[panel]; acc },
      },
    },
  })
end
