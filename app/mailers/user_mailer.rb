class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @greeting = 'Hello'
    subject = 'ProSafeT Reset Password Instructions'
    attachments.inline['logo.png'] = File.read("#{Rails.root}/public/ProSafeT_logo_final.png")
    mail(**to_email(@user.email), subject: subject)
  end
end
