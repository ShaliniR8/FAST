class AddPanelCategory < ActiveRecord::Migration
  def self.up
    add_column :categories,:panel,:string
  end

  def self.down
  	remove_column :categories,:panel
  end
end
