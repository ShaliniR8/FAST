PrdgSession::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  # config.cache_store = :memory_store
  # config.cache_store = :file_store, "/home/saptarshi/ProSafeTv1.2.6/test_cache"
  config.cache_store = :null_store

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  host = '74.208.18.182:3002'
  config.action_mailer.default_url_options = {host: host, protocol: "http"}

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin


  config.log_level = :debug
  # config.after_initialize do
 #    Bullet.enable        = true
 #    Bullet.alert         = true
 #    Bullet.bullet_logger = true
 #    Bullet.console       = true
 #  # Bullet.growl         = true
 #    Bullet.rails_logger  = true
 #    Bullet.add_footer    = true
 #  end
end


