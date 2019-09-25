class AddAnonymousToMessageAccesses < ActiveRecord::Migration
  def self.up
    add_column :message_accesses, :anonymous, :boolean, :default => false
  end

  def self.down
    remove_column :message_accesses, :anonymous
  end
end
