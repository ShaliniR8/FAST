require 'csv'

CSV.open("#{Dir.pwd}/privileges.csv", "wb") do |csv|
	CSV.foreach("#{Dir.pwd}/users.csv", encoding: "utf-8") do |row|
		username = row[0]
		privileges = row[1]
		privileges = privileges.split(",")
		privileges.each do |x| 
			csv << [username, x.strip]
		end
	end
end




