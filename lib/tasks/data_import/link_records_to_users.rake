task :link_records_to_users => :environment do
	objects = JSON.parse(File.read("/home/jiaming/mysql_dumps/miamiair_official_migration/A_Mapping/1103_BSK_datadump/josh/objects.json"))
	sql = ""
	puts objects.first.class
	Record.all.each do |record|
		object = objects.find { |obj| obj["id"] == record.obj_id}

		if object
			users = User.where(first_name: object["first-name-entered"], last_name: object["last-name-entered"])
			if users.length > 0
				user = users.first
				sql += "update records set users_id = #{user.id} where id = #{record.id};\n"
			end
		end
	end
	File.write("#{Rails.root}/lib/tasks/link_records_to_users.sql", sql)
end