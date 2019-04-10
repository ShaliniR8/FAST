task :set_report_status => :environment do
	Report.all.each do |report|
		puts report
	end
end