class AddIsReadyToExportToQueries < ActiveRecord::Migration
  def self.up
    add_column :queries, :is_ready_to_export, :boolean, default: false
  end

  def self.down
    remove_column :queries, :is_ready_to_export
  end
end
