ActionMailer::Base.smtp_settings = { 
  :address              => "smtpout.secureserver.net",
  :port                 => 80,
  :domain               => "prodigiq.com",
  :user_name            => "engineering@prodigiq.com",
  :password             => "jaguar1995",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
