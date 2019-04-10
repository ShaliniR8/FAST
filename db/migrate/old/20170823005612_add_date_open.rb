class AddDateOpen < ActiveRecord::Migration
  def self.up
    add_column :ims,:date_open,:date
  end

  def self.down
    remove_column :ims,:date_open
  end
end
