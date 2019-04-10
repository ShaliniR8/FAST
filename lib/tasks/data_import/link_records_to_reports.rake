task :link_records_to_reports => :environment do
	links = JSON.parse(File.read("/home/jiaming/mysql_dumps/miamiair_official_migration/A_Mapping/1103_BSK_datadump/josh/record_report_links.json"))
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