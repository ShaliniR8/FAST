class RenameCauseOptionsHazardToDefault < ActiveRecord::Migration
  def self.up
    CauseOption.where(level: 0, name: 'Hazard').first.update_attributes({name: 'Default'})
  end

  def self.down
    CauseOption.where(level: 0, name: 'Default').first.update_attributes({name: 'Hazard'})
  end
end
