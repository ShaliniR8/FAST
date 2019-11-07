namespace :v1_1_1 do
  logger = Logger.new('log/patch.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  task :patch_all => :environment do
    desc 'Run all updates from v1.1.0 to v1.1.1'
    logger.info '###########################'
    logger.info '### VERSION 1.1.1 PATCH ###'
    logger.info '###########################'
    logger.info "Patch start - #{DateTime.now.strftime("%F %R")}"

    Rake::Task['connection_converter:report_meetings'].invoke()
    Rake::Task['v1_1_1:promote_admins'].invoke()
  end

  task :promote_admins => :environment do
    desc 'Revises all admin users to global admins'
    logger.info 'Promoting all Admins to Global Admins...'
      User.where(level: 'Admin').update_all(level: 'Global Admin')
    logger.info '... Admins promoted.'
  end
end
