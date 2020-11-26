task :link_reports_to_meetings => :environment do

  file = "/home/devuser/taeho/data_import/wbat_data_import/import/data/report_meeting_links.csv"
  File.open(file).each_line do |line|

    report_id, meeting_id =  line.strip.split(',')

    begin
      report = Report.where(obj_id: report_id.to_i).first
    rescue
      p "[FAILED] missing Event ##{report_id}"
    end

    begin
      meeting = Meeting.where(obj_id: meeting_id.to_i).first
    rescue
     p "[FAILED] missing Meeting ##{meeting_id}"
   end

    if report.present? && meeting.present?
      p "[info] Add Event ##{report_id} to Meeting ##{meeting_id}"
      meeting.reports << report
    end

  end

end
