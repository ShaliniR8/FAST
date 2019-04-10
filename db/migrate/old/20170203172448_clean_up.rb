class CleanUp < ActiveRecord::Migration
  def self.up
   drop_table :tags
   drop_table :assignments
  end

  def self.down
  end
end
