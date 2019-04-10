task :link_objects => :environment do
	ARGV.each { |a| task a.to_sym do ; end }#create empty tasks for the args so no errors

	@sql = ""
	@objects_to_link = ARGV[1..ARGV.count]

	@link_all = @objects_to_link.count == 0

	puts "Starting link_objects rake task. linking the following objects:"
	if @link_all
		puts "ALL OBJECTS"
	else
		puts "[#{@objects_to_link.join(',')}]"
	end
	#findings and causes and meetings are special cases, so these are done manually
	if @link_all || @objects_to_link.include?("findings") 
		puts "linking findings to audits"
		Finding.all.each do |finding|
			if finding.audit_obj_id
				matching_audits = Audit.where(obj_id: finding.audit_obj_id)
				if matching_audits.count > 0
					 @sql += "update findings set audit_id = #{matching_audits.first.id} where id = #{finding.id};\n"
				else
					puts "Found no matching audits, skipping"
				end
			end
		end
	end

	if @link_all || @objects_to_link.include?("causes") 
		puts "linking causes"
		@sql += "insert into causes (id, owner_id) values"
		findings_by_obj_id = {}
		Finding.all.each do |finding|
			findings_by_obj_id[finding.obj_id] = finding if finding.obj_id
		end
		investigations_by_obj_id = {}
		Investigation.all.each do |investigation|
			investigations_by_obj_id[investigation.obj_id] = investigation if investigation.obj_id
		end
		records_by_obj_id = {}
		Record.all.each do |record|
			records_by_obj_id[record.obj_id] = record if record.obj_id
		end
		sms_actions_by_obj_id = {}
		SmsAction.all.each do |sms_action|
			sms_actions_by_obj_id[sms_action.obj_id] = sms_action if sms_action.obj_id
		end
		reports_by_obj_id = {}
		Report.all.each do |report|
			reports_by_obj_id[report.obj_id] = report if report.obj_id
		end
		recommendations_by_obj_id = {}
		Recommendation.all.each do |recommendation|
			recommendations_by_obj_id[recommendation.obj_id] = recommendation if recommendation.obj_id
		end
		Cause.all.each do |cause|
			if cause.obj_id
				if cause.type.start_with?("Finding")
					if findings_by_obj_id[cause.obj_id]
						@sql += "(#{cause.id}, #{findings_by_obj_id[cause.obj_id].id}),"
					end
				elsif cause.type.start_with?("Investigation")
					if investigations_by_obj_id[cause.obj_id]
						@sql += "(#{cause.id}, #{investigations_by_obj_id[cause.obj_id].id}),"
					end
				elsif cause.type.start_with?("Record")
					if records_by_obj_id[cause.obj_id]
						@sql += "(#{cause.id}, #{records_by_obj_id[cause.obj_id].id}),"
					end
				elsif cause.type.start_with?("SmsAction")
					if sms_actions_by_obj_id[cause.obj_id]
						@sql += "(#{cause.id}, #{sms_actions_by_obj_id[cause.obj_id].id}),"
					end
				elsif cause.type.start_with?("Report")
					if reports_by_obj_id[cause.obj_id]
						@sql += "(#{cause.id}, #{reports_by_obj_id[cause.obj_id].id}),"
					end
				elsif cause.type.start_with?("Recommendation")
					if recommendations_by_obj_id[cause.obj_id]
						@sql += "(#{cause.id}, #{recommendations_by_obj_id[cause.obj_id].id}),"
					end
				end
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update owner_id=values(owner_id);\n"
	end

	if @link_all || @objects_to_link.include?("message_accesses")
		puts "linking message accesses"
		@sql += "insert into message_accesses (id, messages_id) values"
		messages_by_outbox_id = {}
		Message.all.each do |m|
			messages_by_outbox_id[m.outbox_id] = m if m.outbox_id
		end
		MessageAccess.all.each do |access|
			if access.message_outbox_id
				if messages_by_outbox_id[access.message_outbox_id]
					@sql += "(#{access.id}, #{messages_by_outbox_id[access.message_outbox_id].id}),"
				else
					puts "Attempt to link message_access #{access.id}, but no message exists with outbox_id #{access.message_outbox_id}"
				end
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update messages_id=values(messages_id);\n"
	end

	if @link_all || @objects_to_link.include?("messages")
		puts "linking messages"
		@sql += "insert into messages (id, response_id) values"
		Message.all.each do |message|
			if message.response_outbox_id
				responses = Message.where(outbox_id: message.response_outbox_id)
				if responses.count > 0
					@sql += "(#{message.id}, #{responses.first.id}),"
				else
					puts "Attempt to link message #{message.id}, but no message exists with outbox_id #{message.response_outbox_id}"
				end
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update response_id=values(response_id);\n"
	end

	if @link_all || @objects_to_link.include?("participations")
		@sql += "insert into participations (id, meetings_id) values"
		Participation.all.each do |particip|
			if particip.obj_id
				meetings = Meeting.where(obj_id: particip.obj_id)
				if meetings.length > 0
					@sql += "(#{particip.id}, #{meetings.first.id}),"
				else
					puts "meetint obj id #{particip.obj_id} not found"
				end
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update meetings_id=values(meetings_id);\n"
	end

	if @link_all || @objects_to_link.include?("attachments")
		puts "linking attachments to messages"
		#attachment obj_id links to message outbox_id
		@sql += "insert into attachments (id, owner_id) values"
		messages_by_outbox_id = {}
		Message.all.each do |m|
			messages_by_outbox_id[m.outbox_id] = m if m.outbox_id
		end
		Attachment.where("type = 'MessageAttachment'").each do |attachment|
			if attachment.obj_id
				if messages_by_outbox_id[attachment.obj_id]
					@sql += "(#{attachment.id}, #{messages_by_outbox_id[attachment.obj_id].id}),"
				else
					puts "message not found with outbox_id #{attachment.obj_id}"
				end
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update owner_id=values(owner_id);\n"
	end

	if @link_all || @objects_to_link.include?("corrective_actions")
		puts "Linking corrective_actions"
		@sql += "insert into corrective_actions (id, records_id) values"
		records_by_obj_id = {}
		Record.all.each do |m|
			records_by_obj_id[m.obj_id] = m if m.obj_id
		end
		CorrectiveAction.all.each do |corrective_action|
			if corrective_action.obj_id
				if records_by_obj_id[corrective_action.obj_id]
					@sql += "(#{corrective_action.id}, #{records_by_obj_id[corrective_action.obj_id].id}),"
				else
					puts "record not found with obj_id #{corrective_action.obj_id}"
				end
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update records_id=values(records_id);\n"
	end


	link_items(Recommendation, {"FindingRecommendation"=> Finding, "InvestigationRecommendation"=> Investigation}, :owner_obj_id)
	link_items(SmsAction, {"FindingAction"=> Finding, "InvestigationAction"=> Investigation}, :owner_obj_id)
	link_items(SmsTask, {"AuditTask"=> Audit, "InspectionTask"=> Inspection, "InvestigationTask"=> Investigation, "EvaluationTask"=> Evaluation, "FindingTask" => Finding}, :owner_obj_id)
	link_items(ChecklistItem,
		{
			"AuditItem" => Audit,
			"InspectionItem" => Inspection,
			"EvaluationItem"=> Evaluation,
			"FrameworkImItem" => FrameworkIm,
			"VpImItem" => VpIm,
			"JobAidItem" => JobAid,
			},:owner_obj_id)

	link_items(Transaction, 
		{
			"AuditTransaction" => Audit,
			"FindingTransaction" => Finding,
			"InvestigationTransaction" => Investigation,
			"RecordTransaction" => Record,
			"ReportTransaction" => Report,
			"SubmissionTransaction" => Submission,
			"SmsActionTransaction" => SmsAction,
			"RecommendationTransaction" => Recommendation,
			"ImTransaction" => Im,
			"PackageTransaction" => Package,
			"MeetingTransaction" => Meeting,
		}, :owner_obj_id)

	link_items(Attachment,
		{
			"ImAttachment" => Im,
			"AuditAttachment" => Audit,
			"FindingAttachment" => Finding,
			"InvestigationAttachment" => Investigation,
			"ReportAttachment" => Report,
			"RecordAttachment" => Record,
			"SmsActionAttachment" => SmsAction,
			"SubmissionAttachment" => Submission,
			"RecommendationAttachment" => Recommendation,
			"ChecklistItemAttachment" => ChecklistItem,
			"PackageAttachment" => Package,
		}, :obj_id
	)
	link_items(Contact, {"AuditContact" => Audit, "FindingContact" => Finding}, :obj_id)
	link_items(Package, {"FrameworkImPackage" => ChecklistItem, "JobAidPackage" => ChecklistItem, "VpImPackage" => ChecklistItem}, :owner_obj_id)

	if (@link_all || @objects_to_link.include?("packages"))
		@sql += "insert into packages (id, meeting_id) values"
		meetings_by_obj_id = {}
		Meeting.all.each do |meeting|
			meetings_by_obj_id[meeting.obj_id] = meeting if meeting.obj_id
		end
		Package.all.each do |package|
			if package.meeting_obj_id
				@sql += "(#{package.id}, #{meetings_by_obj_id[package.meeting_obj_id].id}),"
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update meeting_id=values(meeting_id);\n"
	end

	if (@link_all || @objects_to_link.include?("agendas"))
		packages_by_obj_id = Hash[Package.all.map { |x| [x.obj_id, x]}]
		meeting_by_obj_id = Hash[Meeting.all.map { |x| [x.obj_id, x]}]
		@sql += "insert into agendas (id, event_id) values"
		Agenda.all.each do |agenda|
			if agenda.obj_id
				@sql += "(#{agenda.id}, #{packages_by_obj_id[agenda.obj_id].id}),"
			end
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update event_id=values(event_id);\n"

		
	end

	link_users(Audit, {:auditor_poc_id => :auditor_id, :approver_poc_id => :approver_id})
	link_users(Investigation, {:approver_poc_id => :final_approver_id, :investigator_poc_id => :investigator_id})
	link_users(Finding, {:responsible_user_poc_id => :responsible_user_id, :approver_poc_id => :approver_id})
	link_users(SmsAction, {:user_poc_id => :user_id, :approver_poc_id => :approver_id})
	link_users(Recommendation, {:user_poc_id => :user_id})
	link_users(CorrectiveAction, {:user_poc_id => :users_id})
	link_users(Transaction, {:user_poc_id => :users_id})
	link_users(MessageAccess, {:user_poc_id => :users_id})
	link_users(Participation, {:poc_id => :users_id})
	link_users(Im, {:pre_reviewer_poc_id => :pre_reviewer, :lead_evaluator_poc_id => :lead_evaluator})
	link_users(Agenda, {:user_poc_id => :user_id})

	File.write("./lib/tasks/link_objects.sql", @sql)
	puts "Wrote the results of the link to ./lib/tasks/link_objects.sql. Now running the following command:"
	puts "'mysql -u admin -p prosafet_bsk_data_db < lib/tasks/link_objects.sql'"
	puts "This may take some time"
	%x`mysql -u admin -p prosafet_bsk_data_db < lib/tasks/link_objects.sql`

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
	@sql += "insert into #{main_class.table_name} (id, owner_id) values"
	total = main_class.all.count

	main_class.all.each_with_index do |item, i|
		if item.send(foreign_key_obj_id)
			matching_objects = []
			used_link_class = ""
			link_map.each do |link_type, link_class|
				if item.type == link_type
					used_link_class = link_class
					matching_objects = link_class.where("obj_id = ?", item.send(foreign_key_obj_id))#move this out of the loop to improve efficiency
				end
			end
			if matching_objects.count > 0
				@sql += "(#{item.id}, #{matching_objects.first.id}),"
			else
				puts "Attempt to link #{item.type} with id=#{item.id} to #{used_link_class} with obj_id=#{item.send(foreign_key_obj_id)} failed because #{used_link_class} doesn't exist, skipping"
			end
		end
		progress = i.to_f / total.to_f * 100
		print "#{progress.to_i.to_s}%\r"
	end
	@sql.chomp!(",")
	@sql += " on duplicate key update owner_id=values(owner_id);\n"
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
		@sql += "insert into #{main_class.table_name} (id, #{foreign_key}) values"
		main_class.all.each_with_index do |item, i|
			if item.send(poc_key)
				# users = User.where(poc_id: item.send(poc_key))#old way, but it is very slow to have db queries within the for loop
				if users_by_poc_id[item.send(poc_key)]
					@sql += "(#{item.id}, #{users_by_poc_id[item.send(poc_key)].id}),"#@sql += "update #{main_class.table_name} set #{foreign_key} = #{user.id} where id = #{item.id};\n"
				else
					puts "user with poc id #{item.send(poc_key)} not found"
				end
			end
			#progress = i.to_f / main_class.all.count.to_f * 100
			#print "#{progress.to_i.to_s}%\r"
		end
		@sql.chomp!(",")
		@sql += " on duplicate key update #{foreign_key}=values(#{foreign_key});\n"
		
	end
end