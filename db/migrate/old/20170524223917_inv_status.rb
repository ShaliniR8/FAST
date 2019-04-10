class InvStatus < ActiveRecord::Migration
  def self.up
     add_column :investigations,:status,:string,:default=>"New"
  end

  def self.down
     remove_column :investigations,:status
  end
end
