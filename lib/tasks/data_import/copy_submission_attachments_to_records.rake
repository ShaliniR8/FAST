task :copy_submission_attachments_to_records => :environment do
	Attachment.all.each do |attachment|
		if attachment.type == "SubmissionAttachment"
			if attachment.submission

				# puts attachment.submission
				records = Record.where(id: attachment.submission.records_id)
				if records.length > 0
					record = records.first 
					# puts record
					cloned_attachment = attachment.clone
					cloned_attachment.type = "RecordAttachment"
					cloned_attachment.owner_id = record.id
					if cloned_attachment.save
						puts "copied attachment #{attachment.id} from submission #{attachment.submission.id} to #{record.id}"
					else
						puts "Error saving attachment"
					end
				end
			end

		end
	end
end