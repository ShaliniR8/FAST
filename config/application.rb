require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'pdfkit'
require 'oauth/rack/oauth_filter' #Kaushik Mahorker OAuth
# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module PrdgSession
  class Application < Rails::Application
  config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]
  config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}', '{**}')]
  config.autoload_paths << "#{config.root}/lib"    # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Custom directories with classes and modules you want to be autoloadable.
  # config.autoload_paths += %W(#{config.root}/extras)

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named.
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Activate observers that should always be running.
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
   config.time_zone = 'Eastern Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
  config.i18n.locale = :default
  config.i18n.fallbacks = [:default, :en]
  I18n.enforce_available_locales = false


  # JavaScript files you want as :defaults (application.js is always included).
  # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

  # Configure the default encoding used in templates for Ruby 1.9.
  config.encoding = "utf-8"
  Rack::Utils.key_space_limit = 262144

  # Configure sensitive parameters which will be filtered from the log file.
  config.filter_parameters += %i[password pw base64 json_dump]
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  airline_code = YAML.load_file("#{::Rails.root}/config/airline_code.yml")
  airline_code += '-training' if Rails.env.training?
  config.action_mailer.default_url_options = { :host => "#{airline_code}.prosafet.com" }
  config.action_mailer.smtp_settings = {
    address:          ENV['SMTP_ADDRESS'] || 'smtp.1and1.com',
    port:             ENV['SMTP_PORT'] || 587,
    user_name:        ENV['SMTP_USER_NAME'] || 'noc@prosafet.com',
    password:         ENV['SMTP_PASSWORD'] || 'Cupcakes2021!',
    authentication:   ENV['SMTP_AUTHENTICATION'] || 'plain',
    enable_starttls:  (ENV['ENABLE_START_TLS'] == "true") 
  }
  config.action_mailer.raise_delivery_errors = false


  #Kaushik Mahorker OAuth
  config.middleware.use OAuth::Rack::OAuthFilter
  end
end
