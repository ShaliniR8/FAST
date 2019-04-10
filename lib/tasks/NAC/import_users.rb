#!/usr/bin/env ruby

columns_hash = {
	users: "username, module_access, employee_number, first_name, last_name, email, job_title, address, city, state, mobile_number, work_phone_number"
}


def if_y
	puts "(y/n)?"
	yield if STDIN.gets.chomp == 'y'
end


resources = ARGV
num_sql_files = 0
puts "Enter the database name to import into:"
database_name = STDIN.gets.chomp

commands = []
resources.each do |resource|
	columns = columns_hash[resource.to_sym]
	if columns
		command = "load data local infile '#{Dir.pwd}/#{resource}.csv' into table #{resource} character set UTF8 fields terminated by ',' optionally enclosed by '\\\"' (#{columns});"
		commands.push command
	else
		puts "Column list for #{resource} not found, skipping. Please add to columns_hash at the top of 'import_csv.rb'"
		resources.delete(resource)
	end
end


if resources.count == 0
	puts "No resources to import. Closing"
	exit
end


puts "\nStep 1:\nImporting csv files"

csv_command = "mysql -u admin -p #{database_name} -e \"#{commands.join}\""
puts "This will run '#{csv_command}'"
puts "Are you sure?"
if_y { %x`#{csv_command}` }

puts "All done!"