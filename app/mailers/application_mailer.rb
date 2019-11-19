class ApplicationMailer < ActionMailer::Base
  default from: 'engineering@prosafet.com'

  protected
  def to_email(email)
    BaseConfig.airline[:enable_mailer] && Rails.env.production? ?
      email : 'noc@prodigiq.com'
  end
end