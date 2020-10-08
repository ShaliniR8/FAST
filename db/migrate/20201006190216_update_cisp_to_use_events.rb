class UpdateCispToUseEvents < ActiveRecord::Migration

  def self.up
    remove_column :records, :cisp_ready
    remove_column :records, :cisp_sent
    remove_column :reports, :cisp_ready
    add_column    :reports, :cisp_sent, :boolean, default: false
  end


  def self.down
    remove_column :reports, :cisp_sent
    add_column    :reports, :cisp_ready, :boolean, default: false
    add_column    :records, :cisp_sent,  :boolean, default: false
    add_column    :records, :cisp_ready, :boolean, default: false
  end
end
