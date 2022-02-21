class AddRegulatoryViolationToEvent < ActiveRecord::Migration
  def self.up
    add_column :reports, :regulatory_violation, :boolean
  end

  def self.down
    remove_column :reports, :regulatory_violation
  end
end
