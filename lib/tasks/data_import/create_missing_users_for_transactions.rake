task :create_missing_users_for_transactions => :environment do
	Transaction.all.each do |transaction|
		if transaction.user_poc_id.nil? && (transaction.poc_first_name || transaction.poc_last_name)
			puts "Proceesing transaction #{transaction.id} which has a missing user"
			matching_users = User.where(first_name: transaction.poc_first_name, last_name: transaction.poc_last_name)
			if matching_users.length > 0
				puts "Found a matching user"
				user = matching_users.first
			else
				puts "Didnt find a missing user, creating"
				t = transaction
				if t.poc_first_name
					username = "#{t.poc_first_name[0]}#{t.poc_last_name}".downcase.gsub(" ", "")
				else
					username = "#{t.poc_last_name}".downcase.gsub(" ", "")
				end
				user = User.new(
					first_name: t.poc_first_name,
					last_name: t.poc_last_name,
					username: username,
					full_name: t.poc_first_name ? t.poc_first_name + " " + t.poc_last_name : t.poc_last_name
				)
				if user.save(validate: false)
					puts "created user"
				else
					puts "failsed to save user"
				end
			end
			transaction.user = user
			if transaction.save
				puts "saved transaction"
			else
				puts "failed to save transaction"
			end
		end
	end
end