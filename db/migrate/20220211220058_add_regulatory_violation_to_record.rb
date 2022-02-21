class AddRegulatoryViolationToRecord < ActiveRecord::Migration
  def self.up
    add_column :records, :regulatory_violation, :boolean
  end

  def self.down
    remove_column :records, :regulatory_violation
  end
end
