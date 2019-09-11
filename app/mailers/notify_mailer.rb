class NotifyMailer < ActionMailer::Base

  include ApplicationHelper

  default :from => "donotreply@prosafet.com"

  def notify(user, message, subject)
    @user = user
    @message = message
    define_attachments
    subject = "ProSafeT#{subject.nil? ? '' : ": #{subject}"}"
    if CONFIG::GENERAL[:enable_mailer] && Rails.env.production?
      mail(:to => user.email, :subject => subject).deliver
    end
    mail(:to => 'noc@prosafet.com', :subject => subject).deliver
  end


  def share_private_link(shared_by, private_link)
    @private_link = private_link
    @email = private_link.email
    define_attachments
    @subject = "New shared link on ProSafeT"
    link = "<a style='font-weight:bold;text-decoration:underline' href='#{private_links_url(:digest => private_link.digest)}'>View</a>"
    @message = "#{shared_by.full_name} has shared a link with you on ProSafeT. #{link}"

    if CONFIG::GENERAL[:enable_mailer] && Rails.env.production?
      mail(:to => @email, :subject => @subject).deliver
    end
    mail(:to => 'noc@prosafet.com', :subject => subject).deliver
  end


  def automated_reminder(user, subject, message, record)
    @user = user
    @message = message.gsub("\n", "<br>") rescue ''
    @record = record
    @record_url = g_link(record)
    define_attachments
    subject = "ProSafeT: #{subject}"
    if CONFIG::GENERAL[:enable_mailer] && Rails.env.production?
      mail(:to => user.email, :subject => subject).deliver
    end
    mail(:to => 'noc@prosafet.com', :subject => subject).deliver
  end

  def send_submitter_confirmation(user, submission)
    @user = user
    @submission_id = submission.id
    @submission_description = submission.get_description
    @submission_url = g_link(submission)
    define_attachments
    subject = "ProSafeT: Submission ##{submission.id} Received"
    if CONFIG::GENERAL[:enable_mailer] && Rails.env.production?
      mail(to: user.email, subject: subject).deliver
    end
    mail(to: 'noc@prosafet.com', subject: subject).deliver
  end

  helper_method :define_attachments

  def define_attachments
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/ProSafeT_logo_final.png")
  end
end
