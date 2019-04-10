require 'csv'
task :upload_privileges => :environment do 

	CSV.open("#{Dir.pwd}/lib/tasks/NAC/roles.csv", "wb") do |csv|
		CSV.foreach("#{Dir.pwd}/lib/tasks/NAC/privileges.csv") do |row|
			user = User.where(username: row[0]).first
			privilege = Privilege.where(name: row[1]).first
			if user.present? 
				if privilege.present?
					csv << [user.id, privilege.id]
				elsif row[1] == "Admin (Full Access)"
					csv << [user.id, 1]
				end
			end
		end
	end

end