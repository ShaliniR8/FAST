class NotifyMailer < ApplicationMailer
  include ApplicationHelper

  default :from => "donotreply@prosafet.com"


  def notify_rake_errors(subject, error, location)
	    emails = ['engineering@prosafet.com', 'saptarshi.chatterjee@prodigiq.com']
	    default = 'noc@prosafet.com'
	    @error = error
	    @location = location
  	if Rails.env.production?
	    mail(to: emails, subject: subject).deliver
	  else
	    mail(to: default, subject: subject).deliver
	  end
  end

  def notify_user_import_result(subject, body)
    emails = ['pia.wetzel@prodigiq.com','engineering@prosafet.com', 'saptarshi.chatterjee@prodigiq.com'] + CONFIG::CSV_FILE_USER_IMPORT[:client_emails]
    default = 'noc@prosafet.com'
    if Rails.env.production?
      mail(to: emails, subject: subject, body: body).deliver
    else
      mail(to: default, subject: subject, body: body).deliver
    end
  end



  def notify(notice, subject, record, attachment = nil, extra_attachments = 0)
    @user = notice.user
    @notice = notice
    @link = g_link(notice.owner)
    @message = record
    @extra = extra_attachments.to_i
    object_name = record.class.name
    object_id   = record.id
    title       = record.description rescue ''
    if object_name == 'Submission'
      object_id = record.send(CONFIG.sr::HIERARCHY[:objects]['Submission'][:fields][:id][:field])
      submission_type = record.template.name
      filename = "#{object_name}_#{object_id}_#{submission_type}_#{title}"

      attachments["#{filename}.pdf"] = attachment unless attachment.nil?
    elsif object_name == "Message" && record.owner.present?
      title = record.owner.description rescue ''
      filename = "#{record.owner.class.name}_#{record.owner.id}_#{title}"
      attachments["#{filename}.pdf"] = attachment unless attachment.nil?
    end

    if CONFIG::GENERAL[:enable_mailer]
      mail(**to_email(notice.user.email), subject: subject).deliver if notice.user.present?
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


  def automated_reminder(user, subject, message, record, attachment = nil, filename = 0)
    @user = user
    @message = message.gsub('\n', '<br>') rescue ''
    @record = record
    attachments["#{filename}"] = attachment unless attachment.nil?
    case @record.class.name.demodulize
    when 'Verification'
      @record_url = g_link(record.owner)
    else
      @record_url = g_link(record)
    end

    subject = "ProSafeT: #{subject}"
    mail(**to_email(user.email), subject: subject).deliver
  end


  def send_external(user, emails, subject, message, record)
    @user = user
    @message = message.gsub('\n', '<br>') rescue ''
    @record = record

    @record_url = g_link(record)

    subject = "ProSafeT Analyst to Submitter: #{subject}"
    mail(bcc: emails, subject: subject).deliver
  end


  def send_submitter_confirmation(user, submission)
    @user = user
    @submission_id = submission.send(CONFIG.sr::HIERARCHY[:objects]['Submission'][:fields][:id][:field])
    @submission_description = submission.get_description
    @submission_url = g_link(submission)
    @submitter_message = submission.template.submitter_message.gsub("\n", '<br>') rescue nil
    subject = "ProSafeT: Submission ##{@submission_id} Received"
    mail(**to_email(user.email), subject: subject).deliver
  end


  def send_export(email, filename, file)
    email = 'noc@prosafet.com' unless Rails.env.production?
    attachments[filename] = file
    mail(to: email, subject: 'Report Export Complete').deliver
  end


  def send_query_digest(users:users, query:query, file:file)
    emails = users.map(&:email).uniq
    attachments["Query_#{query.id}.pdf"] = file
    @query = query
    default = 'noc@prosafet.com'
    subject = "#{CONFIG::GENERAL[:name]} Query Digest for #{query.title}"

    if Rails.env.production?
      mail(to: emails, subject: subject).deliver
    else
      mail(to: default, subject: subject).deliver
    end
  end

end
