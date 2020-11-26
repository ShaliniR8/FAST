task :link_submissions_to_records => :environment do
	links = JSON.parse(File.read("/home/devuser/taeho/data_import/wbat_data_import/import/data/submission_record_links.json"))
  # links = JSON.parse(File.read("/home/reluser/data_import/wbat_data_import/import/data/submission_record_links.json"))
	links.each do |link|
		submission = Submission.where(obj_id: link["submission_object_id"]).first
		record = Record.where(obj_id: link["record_object_id"]).first
		if submission && record
			submission.records_id = record.id
			submission.save(validate: false)
		end
	end
end
