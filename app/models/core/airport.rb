class Airport < ActiveRecord::Base
  attr_accessible :icao, :iata, :airport_name


  def self.get_header
    {
      "ICAO"    => "icao",
      "IATA"    => "iata",
      "Name"    => "airport_name",
    }
  end
end
