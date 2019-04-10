class SaMailer < ActionMailer::Base
	include ApplicationHelper
	default :from => "engineering@prosafet.com"

	def assign(owner, user, type)
		@type = type
		@owner = owner
		@user = user
		@link = generate_link_to("View", @owner, :use_url => true).html_safe
		if BaseConfig.airline[:sa_mailer]
			if Rails.env.production?
				mail(
					:to => @user.email, 
					:subject => "ProSafeT: #{@type} ##{@owner.id} Assigned").deliver
			else
				puts "ProSafeT: #{@type} ##{@owner.id} Assign @ #{@user.email}"
			end
		end
	end


	def pending(owner, user, type)
		@type = type
		@owner = owner
		@user = user
		@link = generate_link_to("View", @owner, :use_url => true).html_safe
		if BaseConfig.airline[:sa_mailer]
			if Rails.env.production?
		 		mail(
		 			:to => @user.email, 
		 			:subject => "ProSafeT: #{@type} ##{@owner.id} Pending Approval").deliver
		 	else
		 		puts "ProSafeT: #{@type} ##{@owner.id} Pending Approval @ #{@user.email}"
		 	end
		end
	end

	def reject(owner, user, type)
		@type = type
		@owner = owner
		@user = user
		@link = generate_link_to("View", @owner, :use_url => true).html_safe
		if BaseConfig.airline[:sa_mailer]
			if Rails.env.production?
		 		mail(
		 			:to => @user.email, 
		 			:subject => "ProSafeT: #{@type} ##{@owner.id} Rejected").deliver
		 	else
		 		puts "ProSafeT: #{@type} ##{@owner.id} Rejected @ #{@user.email}"
		 	end
		end
	end


	def complete(owner, user, type)
		@type = type
		@owner = owner
		@user = user
		@link = generate_link_to("View", @owner, :use_url => true).html_safe
		if BaseConfig.airline[:sa_mailer]
			if Rails.env.production?
		 		mail(
		 			:to => @user.email, 
		 			:subject => "ProSafeT: #{@type} ##{@owner.id} Completed").deliver
		 	else
		 		puts "ProSafeT: #{@type} ##{@owner.id} Completed @ #{@user.email}"
		 	end
		end
	end


	def reopen(owner, user, type)
		@type = type
		@owner = owner
		@user = user
		@link = generate_link_to("View", @owner, :use_url => true).html_safe
		if BaseConfig.airline[:sa_mailer]
			if Rails.env.production?
		 		mail(
		 			:to => @user.email, 
		 			:subject => "ProSafeT: #{@type} ##{@owner.id} Reopened and Assigned").deliver
		 	else
		 		puts "ProSafeT: #{@type} ##{@owner.id} Reopened and Assigned @ #{@user.email}"
		 	end
		end
	end

end