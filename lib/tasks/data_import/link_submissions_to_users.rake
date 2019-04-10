task :link_submissions_to_users => :environment do
	objects = JSON.parse(File.read("/home/jiaming/mysql_dumps/miamiair_official_migration/A_Mapping/1103_BSK_datadump/josh/objects.json"))
	sql = ""
	puts objects.first.class
	Submission.all.each do |submission|
		object = objects.find { |obj| obj["id"] == submission.obj_id}

		if object
			users = User.where(first_name: object["first-name-entered"], last_name: object["last-name-entered"])
			if users.length > 0
				user = users.first
				sql += "update submissions set user_id = #{user.id} where id = #{submission.id};\n"
			end
		end
	end
	File.write("#{Rails.root}/lib/tasks/link_submissions_to_users.sql", sql)
end