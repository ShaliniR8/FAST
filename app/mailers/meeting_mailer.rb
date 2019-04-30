class MeetingMailer < ActionMailer::Base
  include ApplicationHelper
  default :from => "engineering@prosafet.com"

  def new_meeting(user, meeting)
    @meeting = meeting
    @user = user
    @link = generate_link_to("View", @meeting, :use_url => true).html_safe
    if Rails.env.production?
      mail(:to => @user.email, :subject => "ProSafeT: New Meeting Notification").deliver
    else
      puts "ProSafeT: New Meeting Notification @ #{@user.email}"
    end
  end

  def cancel_meeting(user, meeting)
    @meeting = meeting
    @user = user
    if Rails.env.production?
      mail(:to => @user.email, :subject => "ProSafeT: Cancellation of Meeting").deliver
    else
      puts "ProSafeT: Cancellation of Meeting @ #{@user.email}"
    end
  end

  def cancel_invitation(user, meeting)
    @meeting = meeting
    @user = user
    if Rails.env.production?
      mail(:to => @user.email, :subject => "ProSafeT: Cancellation of Invitation").deliver
    else
      puts "ProSafeT: Cancellation of Invitation @ #{@user.email}"
    end
  end

  def update_meeting(user, meeting)
    @meeting = meeting
    @user = user
    @link = generate_link_to("Click to view", @meeting, :use_url => true).html_safe
    if Rails.env.production?
      mail(:to => @user.email, :subject => "ProSafeT: Meeting Info Update").deliver
    else
      puts "ProSafeT: Meeting Info Update @ #{@user.email}"
    end
  end

  def meeting_message(meeting, user, attachment_path, message, subject, sender)
    @message = message
    @user = user
    @meeting = meeting
    if !attachment_path.blank?
      attachments[attachment_path] = File.read(attachment_path)
    end
    if Rails.env.production?
      mail(:to => @user.email, :subject => "ProSafeT: #{subject}").deliver
    else
      puts "ProSafeT: #{subject} @ #{@user.email}"
    end
  end


end
