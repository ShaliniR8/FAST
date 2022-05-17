class ApplicationMailer < ActionMailer::Base
  default from: 'donotreply@prosafet.com'

  protected
  def to_email(email)
    CONFIG::GENERAL[:enable_mailer] && Rails.env.production? ?
      {to: email, bcc: 'noc@prosafet.com'} : {to: 'noc@prodigiq.com'}
  end

  def define_attachments
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/ProSafeT_logo_final.png")
  end

end
