task :set_package_meetings => :environment do
	Agenda.all.each do |agenda|
		package = Package.find(agenda.event_id)
		agenda.owner_id = package.meeting_id
		agenda.save
	end
end
