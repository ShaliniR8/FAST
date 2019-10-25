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

  POSSIBLE_ACTIONS_FOR_CORRECTIVE_ACTION_TRANSACTIONS = [
    'Add Attachment',
    'Approve',
    'Assign',
    'Complete',
    'Completed',
    'Create',
    'Override Status',
    'Save'
  ]

  POSSIBLE_ACTIONS_FOR_RECORD_TRANSACTIONS = [
    'Add Attachment',
    'Add Cause',
    'Add Corrective Action',
    'Add Description',
    'Add Reaction',
    'Add to Event',
    'Close',
    'Copy',
    'Create',
    'Disable Viewer Access',
    'Enable Viewer Access',
    'Mitigated Risk Matrix Modified',
    'Open',
    'Override Status',
    'Reopen',
    'Risk Matrix Modified',
    'Save',
    'Save Baseline Risk',
    'Update'
  ]

  # First pass; set all close_date to most recent "complete" transaction
  CLASSES.each do |class_type|
    class_type.includes(:transactions).where(status: POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES).each do | entry |
      completed_transactions = entry.transactions.select { |trans| POSSIBLE_COMPLETE_ACTIONS_FOR_TRANSACTIONS.include?trans.action }
      most_recent = completed_transactions.max_by { |trans| trans.stamp }
      entry.update_attributes({close_date: most_recent.stamp}) if most_recent.present?
    end
  end

  # Second pass; if close_date is still NULL
  # Corrective Actions: use most recent transaction date as close_date
  CorrectiveAction.includes(:transactions).where(status: POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES).where(close_date: nil).each do | ca |
    transactions = ca.transactions.select { |trans| POSSIBLE_ACTIONS_FOR_CORRECTIVE_ACTION_TRANSACTIONS.include?trans.action }
    most_recent = transactions.max_by { |trans| trans.stamp }
    ca.update_attributes({close_date: most_recent.stamp}) if most_recent.present?
  end

  # Records: use linked report's close date as close_date
  Record.where(status: POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES).where(close_date: nil).each do | record |
    if record.reports_id.present?
      linked_report = Report.where(id: record.reports_id).find { |report| report.id == record.reports_id }
      record.update_attributes({close_date: linked_report.close_date})
    end
  end

  # Records: if there is no linked report, use the most recent transaction as close_date
  Record.includes(:transactions).where(status: POSSIBLE_COMPLETE_STATUSES_FOR_CLASSES).where(close_date: nil).each do | record |
    transactions = record.transactions.select { |trans| POSSIBLE_ACTIONS_FOR_RECORD_TRANSACTIONS.include?trans.action }
    most_recent = transactions.max_by { |trans| trans.stamp }
    record.update_attributes({close_date: most_recent.stamp}) if most_recent.present?
  end

  logger.info 'FINISH Importing Close Dates'
end
