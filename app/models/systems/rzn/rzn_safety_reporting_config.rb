class RZNSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # Airline-Specific Features:

    # show_event_title_in_query:       false,
    show_pdf_column_scoreboard:      true,
  })

end
