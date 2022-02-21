class AddAsapRegulatoryViolationToFaaReport < ActiveRecord::Migration
  def self.up
    add_column :faa_reports, :asap_reg_violation, :integer, :default => 0
  end

  def self.down
    remove_column :faa_reports, :asap_reg_violation
  end
end
