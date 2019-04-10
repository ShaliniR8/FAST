task :link_submissions_to_records => :environment do
	links = JSON.parse(File.read("/home/jiaming/mysql_dumps/miamiair_official_migration/A_Mapping/1103_BSK_datadump/josh/submission_record_links.json"))
	links.each do |link|
		submission = Submission.where(obj_id: link["submission_object_id"]).first
		record = Record.where(obj_id: link["record_object_id"]).first
		if submission && record
			submission.records_id = record.id
			submission.save(validate: false)
		end
	end
end