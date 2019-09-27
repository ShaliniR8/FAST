class RenameRootCauseTypeToOwnerType < ActiveRecord::Migration
  def self.up
    rename_column :root_causes, :type, :owner_type
  end

  def self.down
    rename_column :root_causes, :owner_type, :type
  end
end
