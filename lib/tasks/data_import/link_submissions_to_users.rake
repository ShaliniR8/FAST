task :link_submissions_to_users => :environment do
	objects = JSON.parse(File.read("/home/devuser/taeho/data_import/wbat_data_import/import/data/objects.json"))
	# sql = ""
	puts objects.first.class
	Submission.all.each do |submission|
    next if submission.id < 11037
		object = objects.find { |obj| obj["id"] == submission.obj_id}

    if object
      users = User.where(first_name: object["first-name-entered"], last_name: object["last-name-entered"])
      if users.length > 0
        user = users.first
        # sql += "update submissions set users_id = #{user.id} where id = #{submission.id};\n"
        submission.user_id = user.id
        if submission.save
          p "[info] Submission ##{submission.id} << user: #{user.full_name}"
        else
          p "[WARNING] FAILED TO SAVE: Submission ##{submission.id}"
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

        # sql += "update submissions set users_id = #{user.id} where id = #{submission.id};\n"
        submission.user_id = user.id
        if submission.save
          p "[info] Submission ##{submission.id} << user: #{user.full_name}"
        else
          p "[WARNING] FAILED TO SAVE: Submission ##{submission.id}"
        end
      end
    end
	end
	# File.write("#{Rails.root}/lib/tasks/link_submissions_to_users.sql", sql)
end
