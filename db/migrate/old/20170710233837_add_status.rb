class AddStatus < ActiveRecord::Migration
  def self.up
    add_column :sras,:status,:string,:default=>"New"
  end

  def self.down
    remove_column :sras,:status
  end
end
