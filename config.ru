# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run PrdgSession::Application

if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    User.authenticate(username, password)
  end
end
