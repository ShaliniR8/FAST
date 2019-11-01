namespace :v1_1_2 do
  logger = Logger.new('log/patch.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  task :patch_all => :environment do
    desc 'Run all updates from v1.1.1 to v1.1.2'
    logger.info '###########################'
    logger.info '### VERSION 1.1.2 PATCH ###'
    logger.info '###########################'
    logger.info "Patch start - #{DateTime.now.strftime("%F %R")}"

    Rake::Task['populate_close_date_from_transactions']
  end

 end
