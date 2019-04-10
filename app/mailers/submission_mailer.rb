class SubmissionMailer < ActionMailer::Base
	include ApplicationHelper
	default :from => "engineering@prosafet.com"


	def notify_analyst(analyst, submission)
		@submission = submission
		@user = analyst
		@link = generate_link_to("View", @submission, :use_url => true).html_safe
		if BaseConfig.airline[:submission_mailer]
			if Rails.env.production?
				mail(:to => analyst.email, :subject => "ProSafeT: New #{@submission.template.name} Submission").deliver
			else
				puts "ProSafeT: New #{@submission.template.name} Submission, deliver to #{analyst.full_name} @ #{analyst.email}"
			end
		end
	end

end