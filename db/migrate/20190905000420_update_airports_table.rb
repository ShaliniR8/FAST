class UpdateAirportsTable < ActiveRecord::Migration
  def self.up

    drop_table :airports

    create_table 'airports', force: true do |t|
      t.string :airport_name
      t.string :icao
      t.string :iata
    end

    execute "INSERT INTO airports SELECT * FROM prosafet_demo_dev_db.airports"

  end

  def self.down
  end
end
