require 'csv'

namespace :v1_1_updates do

  task :update_airports_table => :environment do

    CSV.foreach("#{Rails.root}/lib/tasks/v1_1_updates/airports.csv", :headers => true) do |row|
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

end

