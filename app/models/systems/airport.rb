class Airport < ActiveRecord::Base
	attr_accessible :icao, :faa_host_id, :name


	def self.get_header
		{
			"ICAO"		=> "icao",
			"IATA"		=> "faa_host_id",
			"Name"		=> "name",
		}
	end
end
