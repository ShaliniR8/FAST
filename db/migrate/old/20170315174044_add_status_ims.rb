class AddStatusIms < ActiveRecord::Migration
  def self.up
    add_column :ims,:status,:string,:default=>"New"
  end

  def self.down
    remove_column :ims,:status
  end
end
