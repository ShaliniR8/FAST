namespace :daily_cron_tasks do

  task :all_daily_tasks => :environment do

    #### add the following to cron
    # 0 1 */1 * * /bin/bash -l -c 'cd /home/jiaming/trevor && RAILS_ENV=production /usr/local/bin/bundle exec /usr/local/bin/rake daily_cron_tasks:all_daily_tasks'

    Rake::Task['notifications:automated_notifications'].invoke()
    Rake::Task['recurring:generate_recurrent_forms'].invoke()
    Rake::Task['cache_manager:clear_cache'].invoke()
    Rake::Task['send_daily_digest'].invoke()
    # track_airline_log = BaseConfig.airline[:track_log]
    # Rake::Task['log:summary'].invoke() if track_airline_log
    if defined?(Object.const_get("#{AIRLINE_CODE}Config")::ULTIPRO_DATA)
      Rake::Task['ultipro:update_userbase'].invoke()
    end


    if AIRLINE_CODE == 'FFT'
      Rake::Task['export_query_result'].invoke()
    end
  end

end

