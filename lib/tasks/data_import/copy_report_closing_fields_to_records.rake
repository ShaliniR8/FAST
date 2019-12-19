logger = Logger.new('log/copy_closing_fields.log', File::WRONLY | File::APPEND)
logger.datetime_format = "%Y-%m-%d %H:%M:%S"
logger.formatter = proc do |severity, datetime, progname, msg|
 "[#{datetime}]: #{msg}\n"
end

task :copy_report_closing_fields_to_records => :environment do
  desc 'Import UTC timestamps from transaction log to fill close_date column'

  logger.info 'BEGIN Copying Closing Fields'

  Report.all.each do |report|
    if report.is_asap && report.status = "Closed"
      report.records.each do |record|
        if record.is_asap
          record.update_attributes({
            eir:                  report.eir,
            scoreboard:           report.scoreboard,
            asap:                 report.asap,
            sole:                 report.sole,
            disposition:          report.disposition,
            company_disposition:  report.company_disposition,
            narrative:            report.narrative,
            regulation:           report.regulation,
            notes:                report.notes
          })
        end
      end
    end
  end

  logger.info 'FINISH Copying Closing Fields'
end
