namespace :connection_converter do
  logger = Logger.new('log/patch.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  desc 'Converts ReportMeetings join table with Connection objects'
  task :report_meetings => :environment do
    logger.info 'Converting ReportMeeting Objects to Connection Objects...'
    Connection.transaction do
      ReportMeeting.includes(:report, :meeting).all.each do |pair|
        Connection.create(owner: pair.meeting, child: pair.report)
      end
    end
    logger.info '... ReportMeetings successfully converted to Connections.'
  end

end
