class MessageMailer < ActionMailer::Base
  include ApplicationHelper
  default :from => "engineering@prosafet.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:

  def new_message(user)
    @user = user
    if BaseConfig.airline[:enable_message_mailer]
      if Rails.env.production?
        mail(:to => @user.email,:subject=> "ProSafeT: New Internal Message").deliver
      else
        puts "New Internal Message @ #{@user.email}"
      end
    end
  end



end
