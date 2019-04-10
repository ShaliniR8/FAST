class UpdateAirportTable < ActiveRecord::Migration
  def self.up
  	remove_column :airports, :icao_code
  	remove_column :airports, :iata_code
  	remove_column :airports, :name
  	remove_column :airports, :city
  	remove_column :airports, :country
  	remove_column :airports, :lat_deg
  	remove_column :airports, :lat_min
  	remove_column :airports, :lat_sec
  	remove_column :airports, :lat_dir
  	remove_column :airports, :lon_deg
  	remove_column :airports, :lon_min
  	remove_column :airports, :lon_sec
  	remove_column :airports, :lon_dir
  	remove_column :airports, :altitude
  	remove_column :airports, :lat_decimal
  	remove_column :airports, :lon_decimal

  	add_column :airports, :arpt_ident, 			:string
  	add_column :airports, :name, 				:string
  	add_column :airports, :state_prov, 			:string
  	add_column :airports, :icao, 				:string
  	add_column :airports, :faa_host_id, 		:string
  	add_column :airports, :loc_hdatum, 			:string
  	add_column :airports, :wgs_datum,			:string
  	add_column :airports, :wgs_lat,				:string
  	add_column :airports, :wgs_dlat,			:string
  	add_column :airports, :wgs_long,			:string
  	add_column :airports, :wgs_dlong,			:string
  	add_column :airports, :elev,				:string
  	add_column :airports, :arpt_type,				:string
  	add_column :airports, :mag_var,				:string
  	add_column :airports, :wac,					:string
  	add_column :airports, :beacon,				:string
  	add_column :airports, :second_arpt,			:string
  	add_column :airports, :opr_agy,				:string
  	add_column :airports, :sec_name,			:string
  	add_column :airports, :sec_icao,			:string
  	add_column :airports, :sec_faa,				:string
  	add_column :airports, :sec_opr_agy,			:string
  	add_column :airports, :cycle_date,			:string
  	add_column :airports, :_id,					:string

  end

  def self.down
  end
end
