require 'csv'

namespace :v1_1_0 do

  task :patch_all => :environment do
    desc 'Run all updates from v1.0.3 to v1.1.0'
    Rake::Task['v1_1_0:update_anonymous_reports'].invoke()
    Rake::Task['v1_1_0:update_airports_table'].invoke()
    Rake::Task['v1_1_0:relocate_attachments'].invoke()
  end

  task :update_airports_table => :environment do
    desc 'Loads elements for the internal airports list (requires v1_1_airports.csv)'
    CSV.foreach("#{Rails.root.join('lib', 'tasks', 'update_patches', 'v1_1_airports.csv')}", :headers => true) do |row|
      Airport.transaction do
        iata = row[4] == '\N' ? '' : row[4]
        icao = row[5] == '\N' ? '' : row[5]
        Airport.create({
          airport_name: row[1],
          icao: icao,
          iata: iata
        })
      end
    end
  end

  task :update_anonymous_reports => :environment do
    desc 'Update historical anonymous transactions.'

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
  end

  task :relocate_attachments => :environment do
    desc 'Moves all class-specific attachments to the polymorphic attachments/name directory'
    uploads_path = Rails.root.join('public', 'uploads')
    mkdir_p uploads_path.join('attachment', 'name')
    `mv #{uploads_path.join('*','name','*')} #{uploads_path.join('attachment', 'name')}`
  end


end
