class AJTSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # Airline-Specific Features:
    attach_pdf_submission:           'none',      # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
    show_pdf_column_scoreboard:      true,
  })

end
