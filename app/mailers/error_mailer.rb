class ErrorMailer < ApplicationMailer
  def mobile_debug_report(user, device_info, app_info, message, json_dump)
    @user = user
    @message = message
    @device_info = device_info
    @app_info = app_info
    subject = "#{BaseConfig.airline[:code]} Mobile Debug Report sent from #{user.full_name}"
    attachments['debug_report.json'] = { mime_type: 'application/json', content: json_dump }
    mail(to: to_email('engineering@prosafet.com'), subject: subject).deliver
  end
end