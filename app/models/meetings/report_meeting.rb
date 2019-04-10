class ReportMeeting < ActiveRecord::Base
	belongs_to :meeting,foreign_key: "meeting_id",class_name: "Meeting"
	belongs_to :report,foreign_key: "report_id",class_name:"Report"
end
