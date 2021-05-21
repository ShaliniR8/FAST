class UserUpdateMailer < ApplicationMailer
  include ApplicationHelper

  default :from => "donotreply@prosafet.com"

  # 'engineering@prosafet.com', 'saptarshi.chatterjee@prodigiq.com', 'taeho.kim@prodigiq.com'

  def notify_user_errors(subject)
	    emails = ['pia.wetzel@prodigiq.com']
	    default = 'noc@prosafet.com'
  	if Rails.env.production?
	    mail(to: emails, subject: subject).deliver
	  else
	    mail(to: default, subject: subject).deliver
	  end
  end

  
end
