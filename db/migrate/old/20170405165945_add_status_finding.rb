class AddStatusFinding < ActiveRecord::Migration
  def self.up
     add_column :findings,:status,:string,:default=>"New"
  end

  def self.down
  end
end
