logger = Logger.new('log/close_date_patch.log', File::WRONLY | File::APPEND)
logger.datetime_format = "%Y-%m-%d %H:%M:%S"
logger.formatter = proc do |severity, datetime, progname, msg|
 "[#{datetime}]: #{msg}\n"
end

task :populate_close_date_from_transactions => :environment do
  desc 'Import UTC timestamps from transaction log to fill close_date column'

  logger.info 'BEGIN Importing Close Dates'

  CLASSES = [
    Audit,
    CorrectiveAction,
    Evaluation,
    Finding,
    Hazard,
    Inspection,
    Investigation,
    Recommendation,
    Record,
    Report,
    RiskControl,
    SafetyPlan,
    SmsAction,
    Sra
  ]

  POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES = [
    'Completed',
    'Closed'
  ]

  POSSIBLE_COMPLETE_ACTIONS_FOR_TRANSACTIONS = [
    'Close',
    'Close Event',
    'Complete',
    'Completed'
  ]

  # First pass; set all close_date to most recent "complete" transaction
  CLASSES.each do |class_type|
    class_type.includes(:transactions).where(status: POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES).where(close_date: nil).each do | entry |
      completed_transactions = entry.transactions.select { |trans| POSSIBLE_COMPLETE_ACTIONS_FOR_TRANSACTIONS.include?trans.action }
      most_recent = completed_transactions.max_by { |trans| trans.stamp }
      entry.update_attributes({close_date: most_recent.stamp}) if most_recent.present?
    end
  end

  # Special case:
  # Records: use linked report's close date as record's close_date
  Record.where(status: POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES).where(close_date: nil).each do | record |
    if record.reports_id.present?
      linked_report = Report.where(id: record.reports_id).find { |report| report.id == record.reports_id }
      record.update_attributes({close_date: linked_report.close_date})
    end
  end

  # Second pass; if close_date is still NULL, use most recent transaction date as close_date
  CLASSES.each do |class_type|
    class_type.includes(:transactions).where(status: POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES).where(close_date: nil).each do | entry |
      most_recent = entry.transactions.max_by { |trans| trans.stamp }
      entry.update_attributes({close_date: most_recent.stamp}) if most_recent.present?
    end
  end

  logger.info 'FINISH Importing Close Dates'
end
