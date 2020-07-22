class NotifyMailer < ApplicationMailer
  include ApplicationHelper

  default :from => "donotreply@prosafet.com"


  def notify(notice, subject, record, attachment = nil)
    define_attachments
    @user = notice.user
    @notice = notice
    @link = g_link(notice.owner)
    @message = record
    if CONFIG::GENERAL[:enable_mailer] && Rails.env.production?
      mail(**to_email(notice.user.email), subject: subject).deliver
    end

    object_name = record.class.name
    object_id   = record.id
    title       = record.description rescue ''

    if object_name == 'Submission'
      submission_type = record.template.name
      filename = "#{object_name}_#{object_id}_#{submission_type}_#{title}"
    else
      object_name = 'Report' if object_name == 'Record'
      filename = "#{object_name}_#{object_id}_#{title}"
    end

    attachments["#{filename}.pdf"] = attachment unless attachment.nil?
    mail(to: 'noc@prosafet.com', subject: subject).deliver
  end


  def share_private_link(shared_by, private_link)
    @private_link = private_link
    @email = private_link.email
    define_attachments
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
    define_attachments
    subject = "ProSafeT: #{subject}"
    mail(**to_email(user.email), subject: subject).deliver
  end

  def send_submitter_confirmation(user, submission)
    @user = user
    @submission_id = submission.id
    @submission_description = submission.get_description
    @submission_url = g_link(submission)
    define_attachments
    subject = "ProSafeT: Submission ##{submission.id} Received"
    mail(**to_email(user.email), subject: subject).deliver
  end

end
