task :link_objects => :environment do
	ARGV.each { |a| task a.to_sym do ; end }#create empty tasks for the args so no errors

	@sql = ""
	@objects_to_link = ARGV[1..ARGV.count]

	@link_all = @objects_to_link.count == 0



	link_items(Transaction,
		{
			"Audit" => Audit,
			"Finding" => Finding,
			"Investigation" => Investigation,
			"Record" => Record,
			"Report" => Report,
			"Submission" => Submission,
			"SmsAction" => SmsAction,
			"Recommendation" => Recommendation,
			"Im" => Im,
			"Package" => Package,
			"Meeting" => Meeting,
		}, :owner_obj_id)


	link_users(Transaction, {:user_poc_id => :users_id})


	File.write("./lib/tasks/link_objects.sql", @sql)
	puts "Wrote the results of the link to ./lib/tasks/link_objects.sql. Now running the following command:"
	puts "'mysql -u admin -p prosafet_fft_dev_db < lib/tasks/link_objects.sql'"
	puts "This may take some time"
	%x`mysql -u admin -p prosafet_fft_dev_db < lib/tasks/link_objects.sql`

end

#link items in a table  to their parent by setting owner id. Single table inheritance is assumed, with link_map being used to map the sti type to the parent object class
#params:
#main_class - the class name to link
#link_map - hash which maps type of the main_class, to the class it should be linked to
#foreign_key_obj_id - the field name of the columns used to store the object-id of the parent object
#note that it is assumed that whichever table is being linked to will have an obj_id field, which will be used to link with foreign_key_obj_id
def link_items(main_class, link_map, foreign_key_obj_id)
	return if !(@link_all || @objects_to_link.include?(main_class.table_name))
	puts "linking #{main_class.table_name}"
	temp_sql = "insert into #{main_class.table_name} (id, owner_id) values"
  count = 0
	total = main_class.all.count

	main_class.all.each_with_index do |item, i|
		if item.send(foreign_key_obj_id)
			matching_objects = []
			used_link_class = ""
			link_map.each do |link_type, link_class|
				if item.owner_type == link_type
					used_link_class = link_class
					matching_objects = link_class.where("obj_id = ?", item.send(foreign_key_obj_id))#move this out of the loop to improve efficiency
				end
			end
			if matching_objects.count > 0
				temp_sql += "(#{item.id}, #{matching_objects.first.id}),"
        count += 1
			else
				puts "Attempt to link #{item.owner_type} with id=#{item.id} to #{used_link_class} with obj_id=#{item.send(foreign_key_obj_id)} failed because #{used_link_class} doesn't exist, skipping"
			end
		end
		progress = i.to_f / total.to_f * 100
		print "#{progress.to_i.to_s}%\r"
	end
	temp_sql.chomp!(",")
	temp_sql += " on duplicate key update owner_id=values(owner_id);\n"

  @sql = count > 0 ? temp_sql : ''
end

# def link_items_detailed(main_class, link_map, foreign_key_obj_id)
# 	return if !(@link_all || @objects_to_link.include?(main_class.table_name))
# 	puts "linking #{main_class.table_name}"
# 	total = main_class.all.count
# 	main_class.all.each_with_index do |item, i|
# 		if item.send(foreign_key_obj_id)
# 			matching_objects = []
# 			used_link_class = ""
# 			link_map.each do |link_type, link_hash|
# 				if item.type == link_type
# 					used_link_class = link_hash[:type]
# 					matching_objects = link_hash[:type].where("obj_id = ?", item.send(foreign_key_obj_id))
# 				end
# 				if matching_objects.count > 0
# 					@sql += "insert into #{main_class.table_name} (id, #{link_hash[:key]}) values"
# 					@sql += "(#{item.id}, #{matching_objects.first.id}),"
# 					@sql.chomp!(",")
# 					@sql += " on duplicate key update #{link_hash[:key]}=values(#{link_hash[:key]});\n"
# 				else
# 					#puts "Attempt to link #{item.type} with id=#{item.id} to #{used_link_class} with obj_id=#{item.send(foreign_key_obj_id)} failed because #{used_link_class} doesn't exist, skipping"
# 				end
# 			end
# 		end
# 		progress = i.to_f / total.to_f * 100
# 		print "#{progress.to_i.to_s}%\r"
# 	end
# end

def link_users(main_class, link_map)
	return if !(@link_all || @objects_to_link.include?(main_class.table_name))
	puts "linking #{main_class.table_name} to users"
	users_by_poc_id = {}
	User.all.each do |user|
		users_by_poc_id[user.poc_id] = user if user.poc_id
	end
	link_map.each do |poc_key, foreign_key|
		temp_sql = "insert into #{main_class.table_name} (id, #{foreign_key}) values"
    count = 0
		main_class.all.each_with_index do |item, i|
			if item.send(poc_key)
				# users = User.where(poc_id: item.send(poc_key))#old way, but it is very slow to have db queries within the for loop
				if users_by_poc_id[item.send(poc_key)]
					temp_sql += "(#{item.id}, #{users_by_poc_id[item.send(poc_key)].id}),"#@sql += "update #{main_class.table_name} set #{foreign_key} = #{user.id} where id = #{item.id};\n"
				  count += 1
        else
					puts "user with poc id #{item.send(poc_key)} not found"
				end
			end
			#progress = i.to_f / main_class.all.count.to_f * 100
			#print "#{progress.to_i.to_s}%\r"
		end
		temp_sql.chomp!(",")
		temp_sql += " on duplicate key update #{foreign_key}=values(#{foreign_key});\n"

    @sql = count > 0 ? temp_sql : ''
	end
end
