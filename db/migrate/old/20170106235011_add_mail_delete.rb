class AddMailDelete < ActiveRecord::Migration
  def self.up
  	add_column :message_accesses, :visible, :boolean
  end

  def self.down
  	remove_column :message_accesses, :visible
  end
end
