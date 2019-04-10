task :update_submission_fields_airport => :environment do

	# Get submission fields where stores airport info
	submission_fields = SubmissionField.where("fields_id in (select id from fields where label like '%airport%') and value<>'' and value is not null")

	# store icao and iata value


	submission_fields.each do |x|
		iata = x.value.split(";")[0]
		icao = x.value.split(";")[1]
		airports = Airport.where(:icao => icao, :faa_host_id => iata)
		#x.value = airports.first.icao
		if airports.present?
			#puts "#{x.value} ======> #{airports.first.icao}"
			x.value = "#{airports.first.icao};#{airports.first.faa_host_id}"
		else
			airports2 = Airport.where(:icao => icao)
			if airports2.present?
				x.value = "#{airports2.first.icao};#{airports2.first.faa_host_id}"
			else
				airports3 = Airport.where(:faa_host_id => icao)
				if airports3.present?
					x.value = "#{airports3.first.icao};#{airports3.first.faa_host_id}"
				else
					puts "#{x.value}"
				end
			end
		end
		x.save
	end


end