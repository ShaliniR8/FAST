class RPASafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # Airline-Specific Features:
    attach_pdf_submission:           'deid',      # 1: ided (identified pdf), 2: deid (deidentified pdf), 3: none (no pdf attachment)
  })

end
