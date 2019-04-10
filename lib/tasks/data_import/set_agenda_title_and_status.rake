task :set_agenda_title_and_status => :environment do
	packages_by_id = Hash[Package.all.map { |x| [x.id, x]}]
	Agenda.all.each do |agenda|
		if packages_by_id.has_key?(agenda.event_id)
			package = packages_by_id[agenda.event_id]
			status = package.status == "Awaiting Review" ? "New" : package.status
			#avoid setting the updated_at column
			ActiveRecord::Base.connection.execute("update agendas set title = \"#{package.title}\", status = \"#{status}\" where id = #{agenda.id};")
		end
	end
end