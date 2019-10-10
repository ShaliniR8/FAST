class NotifyMailer < ActionMailer::Base

  include ApplicationHelper

  default :from => "engineering@prosafet.com"


  def notify(user, message, subject)
    @user = user
    @message = message
    subject = "ProSafeT#{subject.nil? ? '' : ": #{subject}"}"
    if BaseConfig.airline[:enable_mailer]
      if Rails.env.production?
        mail(:to => user.email, :subject => subject).deliver
      else
        mail(:to => 'noc@prodigiq.com', :subject => subject).deliver
      end
    else
      mail(:to => 'noc@prodigiq.com', :subject => subject).deliver
    end
  end


  def share_private_link(shared_by, private_link)
    @private_link = private_link
    @email = private_link.email
    @subject = "New shared link on ProSafeT"
    link = "<a style='font-weight:bold;text-decoration:underline' href='#{private_links_url(:digest => private_link.digest)}'>View</a>"
    @message = "#{shared_by.full_name} has shared a link with you on ProSafeT. #{link}"

    if BaseConfig.airline[:enable_mailer]
      if Rails.env.production?
        mail(:to => @email, :subject => @subject).deliver
      else
        mail(:to => 'noc@prodigiq.com', :subject => @subject).deliver
      end
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
    if BaseConfig.airline[:enable_mailer]
      if Rails.env.production?
        mail(:to => user.email, :subject => subject).deliver
      else
        mail(:to => 'noc@prodigiq.com', :subject => subject).deliver
      end
    else
      mail(:to => 'noc@prodigiq.com', :subject => subject).deliver
    end
  end

  def send_submitter_confirmation(user, submission)
    @user = user
    @submission_id = submission.id
    @submission_description = submission.get_description
    @submission_url = g_link(submission)
    subject = "ProSafeT: Submission ##{submission.id} Received"
    if BaseConfig.airline[:enable_mailer] && Rails.env.production?
      mail(to: user.email, subject: subject).deliver
    else
      mail(to: 'noc@prodigiq.com', subject: subject).deliver
    end
  end


end
