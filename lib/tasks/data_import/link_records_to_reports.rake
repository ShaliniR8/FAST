task :link_records_to_reports => :environment do
	links = JSON.parse(File.read("/home/devuser/taeho/data_import/wbat_data_import/import/data/record_report_links.json"))
	links.each do |link|
		puts link
		record = Record.where(obj_id: link["record_object_id"]).first
		report = Report.where(obj_id: link["report_object_id"]).first
		if record && report
			record.report = report
			record.save
		end
	end
end
