#!/usr/bin/env ruby
require 'rake'

database_name = "prosafet_bsk_data_db"
rails_dir = "/home/jiaming/wbat_system_v1_0_dev/"

task_list = [
	"link_submissions_to_records",
	"link_submissions_to_users",
	"copy_submission_attachments_to_records",
	"link_records_to_reports",
	"link_records_to_users",
	#{}"link_objects",
	# "id_to_title_if_blank",
	"create_missing_users_for_transactions",
	"set_package_meetings",
	"set_agenda_title_and_status",
]

sql_to_run = [
	# "id_to_title_if_blank.sql",
	"link_submissions_to_users.sql",
	"link_records_to_users.sql",
	#{}"link_objects.sql",
]
# task_dir = "#{Rails.root}/lib/tasks"
# Dir.foreach(task_dir) do |task|
# 	if task != "." && task != ".." && File.extname(task) == ".rake"
# 		task_list.push(File.basename(task,File.extname(task)))
# 	end
# end
# puts task_list

task_list.each do |task|
	puts "Running task #{task}..."
	%x(cd #{rails_dir} && rake #{task})
	# Rake::Task[task].invoke
end

command = "cat #{sql_to_run.join(' ')} | mysql -u admin -p #{database_name}"
puts "I can run the generating sql with the following command: #{command}"
puts "Shall I proceed? (y/n)"
if STDIN.gets.chomp == "y"
	%x`#{command}`
end
puts "Post processing complete"

