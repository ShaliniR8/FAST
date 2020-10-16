class NotifyMailer < ApplicationMailer
  include ApplicationHelper

  default :from => "donotreply@prosafet.com"


  def notify_rake_errors(subject, error, location)
	    emails = ['blair.li@prodigiq.com', 'taeho.kim@prodigiq.com', 'trevor.ryles@prodigiq.com', 'engineering@prosafet.com']
	    default = 'noc@prodigiq.com'
	    @error = error
	    @location = location
  	if Rails.env.production?
	    mail(to: emails, subject: subject).deliver
	  else
	    mail(to: default, subject: subject).deliver
	  end
  end

  def notify(notice, subject, record, attachment = nil)
    @user = notice.user
    @notice = notice
    @link = g_link(notice.owner)
    @message = record
    object_name = record.class.name
    object_id   = record.id
    title       = record.description rescue ''
    if object_name == 'Submission'
      submission_type = record.template.name
      filename = "#{object_name}_#{object_id}_#{submission_type}_#{title}"

      attachments["#{filename}.pdf"] = attachment unless attachment.nil?
    end

    if CONFIG::GENERAL[:enable_mailer]
      mail(**to_email(notice.user.email), subject: subject).deliver
    end
  end


  def share_private_link(shared_by, private_link)
    @private_link = private_link
    @email = private_link.email
    @subject = 'New shared link on ProSafeT'
    link = "<a style='font-weight:bold;text-decoration:underline' href='#{private_links_url(digest: private_link.digest)}'>View</a>"
    @message = "#{shared_by.full_name} has shared a link with you on ProSafeT. #{link}"

    mail(**to_email(@email), subject: @subject).deliver
  end


  def automated_reminder(user, subject, message, record)
    @user = user
    @message = message.gsub('\n', '<br>') rescue ''
    @record = record
    @record_url = g_link(record)
    subject = "ProSafeT: #{subject}"
    mail(**to_email(user.email), subject: subject).deliver
  end

  def send_submitter_confirmation(user, submission)
    @user = user
    @submission_id = submission.id
    @submission_description = submission.get_description
    @submission_url = g_link(submission)
    @submitter_message = submission.template.submitter_message.gsub("\n", '<br>') rescue nil
    subject = "ProSafeT: Submission ##{submission.id} Received"
    mail(**to_email(user.email), subject: subject).deliver
  end

end
