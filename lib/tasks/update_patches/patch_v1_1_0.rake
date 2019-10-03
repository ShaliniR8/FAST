require 'csv'

namespace :v1_1_0 do
  logger = Logger.new('log/patch.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  desc 'Run all updates from v1.0.3 to v1.1.0'
  task :patch_all => :environment do
    logger.info '###########################'
    logger.info '### VERSION 1.1.0 PATCH ###'
    logger.info '###########################'
    logger.info "Patch start - #{DateTime.now.strftime("%F %R")}"
    Rake::Task['v1_1_0:update_anonymous_reports'].invoke()
    # Rake::Task['v1_1_0:update_airports_table'].invoke() #Fetches from Demo_live database in a migration
    Rake::Task['v1_1_0:relocate_attachments'].invoke()
    logger.info "Patch for ProSafeT Finished - #{DateTime.now.strftime("%F %R")}"
  end

  desc 'Loads elements for the internal airports list (requires v1_1_airports.csv)'
  task :update_airports_table => :environment do
    logger.info 'Updating Airports Table from csv...'
    Airport.transaction do
      CSV.foreach("#{Rails.root.join('lib', 'tasks', 'update_patches', 'v1_1_airports.csv')}", :headers => true) do |row|
        iata = row[4] == '\N' ? '' : row[4]
        icao = row[5] == '\N' ? '' : row[5]
        Airport.create({
          airport_name: row[1],
          icao: icao,
          iata: iata
        })
      end
    end
    logger.info '... Airports Table updated.'
  end

  desc 'Update historical anonymous transactions.'
  task :update_anonymous_reports => :environment do
    logger.info 'Updating historical anonymous data...'

    submitter_actions = ['Create', 'Add Attachment', 'Dual Report', 'Add Notes']

    transactions = Submission.where(anonymous: 1)
      .map(&:transactions)
      .flatten
      .select{|transaction| submitter_actions.include? transaction.action}

    transactions += Record.where(anonymous: 1)
      .map(&:transactions)
      .flatten
      .select{|transaction| submitter_actions.include? transaction.action}

    transactions.map{|transaction| transaction.update_attributes({users_id: nil})}
    logger.info '... Historical anonymous data revised.'
  end

  desc 'Moves all class-specific attachments to the polymorphic attachments/name directory'
  task :relocate_attachments => :environment do
    logger.info 'Relocating all attachments...'
    uploads_path = Rails.root.join('public', 'uploads')
    mkdir_p uploads_path.join('attachment', 'name')
    `mv #{uploads_path.join('*','name','*')} #{uploads_path.join('attachment', 'name')}`
    logger.info '... Attachments relocated.'
  end


end
