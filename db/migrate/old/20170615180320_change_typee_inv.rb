class ChangeTypeeInv < ActiveRecord::Migration
  def self.up
  	change_column :investigations,:inv_type,:string  
  end

  def self.down
  
  end
end
