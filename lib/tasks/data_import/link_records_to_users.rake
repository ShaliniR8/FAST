task :link_records_to_users => :environment do
	objects = JSON.parse(File.read("/home/devuser/taeho/data_import/wbat_data_import/import/data/objects.json"))
	# sql = ""
	puts objects.first.class
	Record.all.each do |record|
		object = objects.find { |obj| obj["id"] == record.obj_id}

		if object
			users = User.where(first_name: object["first-name-entered"], last_name: object["last-name-entered"])
			if users.length > 0
				user = users.first
				# sql += "update records set users_id = #{user.id} where id = #{record.id};\n"

        record.users_id = user.id
        if record.save
          p "[info] record ##{record.id} << user: #{user.full_name}"
        else
          p "[WARNING] FAILED TO SAVE: record ##{record.id}"
        end


      else
        user = User.new(
          first_name: object["first-name-entered"],
          last_name: object["last-name-entered"],
          username: object["first-name-entered"] + ' ' + object["last-name-entered"],
          full_name: object["first-name-entered"] + ' ' + object["last-name-entered"],
          disalbe: 1
        )
        if user.save(validate: false)
          puts "created user"
        else
          puts "failsed to save user"
        end

        # sql += "update records set users_id = #{user.id} where id = #{record.id};\n"

        record.users_id = user.id
        if record.save
          p "[info] record ##{record.id} << user: #{user.full_name}"
        else
          p "[WARNING] FAILED TO SAVE: record ##{record.id}"
        end

      end
		end
	end
	# File.write("#{Rails.root}/lib/tasks/link_records_to_users.sql", sql)
end
