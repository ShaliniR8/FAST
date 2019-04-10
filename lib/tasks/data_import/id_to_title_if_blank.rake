task :id_to_title_if_blank => :environment do
	sql = ""	
	Finding.all.each do |finding|
		if finding.title.blank?
			#finding.title = finding.id
			#finding.save(validate: false)
			 sql += "update findings set title = '#{finding.id}' where id = #{finding.id};\n"
		end
	end

	Recommendation.all.each do |rec|
		if rec.title.blank?
			# rec.title = rec.id
			# rec.save(validate: false)
			sql += "update recommendations set title = '#{rec.id}' where id = #{rec.id};\n"

		end
	end

	SmsAction.all.each do |sms_action|
		if sms_action.title.blank?
			sql += "update sms_actions set title = '#{sms_action.id}' where id = #{sms_action.id};\n"
			# sms_action.title = sms_action.id
			# sms_action.save(validate: false)
		end
	end
	File.write("./lib/tasks/id_to_title_if_blank.sql", sql)
end