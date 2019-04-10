class CorrectNaming < ActiveRecord::Migration
  def self.up
  
   rename_column :risk_controls, :date_created,:date_complete
  end

  def self.down
  end
end
