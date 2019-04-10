task :convert_weird_chars_to_utf8 => :environment do
	#this should be taken care of during import using 'set names UTF8;', however if there are still weird characters try this script
	puts "Enter the table name:"
	table_name = STDIN.gets.chomp
	puts "Enter the column name:"
	column_name = STDIN.gets.chomp

	command = "update #{table_name} set #{column_name} = convert(cast(convert(#{column_name} using  latin1) as binary) using utf8);"
	ActiveRecord::Base.connection.execute(command)
	puts "data should be fixed now"
end