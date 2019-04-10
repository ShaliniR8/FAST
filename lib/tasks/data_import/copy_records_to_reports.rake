task :copy_records_to_reports => :environment do
	Record.all.each do |record|
		report = Report.new
		report.status = record.status
		report.description = record.description
		report.users_id = record.users_id
		report.custom_id = record.custom_id

		record.transactions.each do |transaction|
			t2 = transaction.clone
			t2
		end
	end
end