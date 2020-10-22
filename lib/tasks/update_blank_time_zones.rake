desc 'Updates blank Submission and Report time zones in SR'
task :update_blank_time_zones => :environment do
  puts 'UPDATING BLANK SUBMISSION AND REPORT TIME ZONES...'
  submissions = Submission.all.select { |s| s.event_time_zone.blank? }.each { |s| s.event_time_zone = 'UTC' }
  Submission.transaction do
    submissions.each(&:save!)
    puts "UPDATED SUBMISSIONS"
  end
  records = Record.all.select { |r| r.event_time_zone.blank? }.each { |r| r.event_time_zone = 'UTC' }
  Record.transaction do
    records.each(&:save!)
    puts "UPDATED REPORTS"
  end
  puts 'DONE'
end



