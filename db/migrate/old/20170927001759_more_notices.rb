class MoreNotices < ActiveRecord::Migration
  def self.up
    add_column	:notices, :action,:string
  end

  def self.down
    remove_column :notices,:action,:string
  end
end
