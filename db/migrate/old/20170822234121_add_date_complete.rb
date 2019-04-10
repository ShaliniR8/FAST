class AddDateComplete < ActiveRecord::Migration
  def self.up
    add_column :ims,:date_complete,:date
  end

  def self.down
  end
end
