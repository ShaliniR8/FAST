class RenameCauseOptionsHazardToDefault < ActiveRecord::Migration
  def self.up
    CauseOption.where(level: 0, name: 'Hazard').first.update_attributes({name: 'Default'}) rescue nil
  end

  def self.down
    CauseOption.where(level: 0, name: 'Default').first.update_attributes({name: 'Hazard'}) rescue nil
  end
end
