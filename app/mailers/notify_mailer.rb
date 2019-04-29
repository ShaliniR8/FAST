class NotifyMailer < ActionMailer::Base

	include ApplicationHelper

	default :from => "engineering@prosafet.com"


	def notify(user, message, subject)
		@user = user
		@message = message
		subject = "ProSafeT#{subject.nil? ? '' : ": #{subject}"}"
		if Rails.env.production?
			mail(:to => user.email, :subject => subject).deliver
		else
			mail(:to => 'noc@prodigiq.com', :subject => subject).deliver
		end
	end


	def automated_reminder(user, subject, message, record)
		@user = user
		@message = message.gsub("\n", "<br>") rescue ''
		@record = record
		@record_url = g_link(record)
		subject = "ProSafeT: #{subject}"
		if Rails.env.production?
			mail(:to => user.email, :subject => subject).deliver
		else
			mail(:to => 'noc@prodigiq.com', :subject => subject).deliver
		end
	end


end
