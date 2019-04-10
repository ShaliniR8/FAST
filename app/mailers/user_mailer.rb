class UserMailer < ActionMailer::Base
  default :from => "engineering@prosafet.com"

  def password_reset(user)
    @user = user
    @greeting = "Hello"
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/ProSafeT_logo_final.png")
    mail to: @user.email, subject: "ProSafeT Reset Password Instructions"
  end
end
