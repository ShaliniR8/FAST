class RenameCausesTypeToOwnerType < ActiveRecord::Migration
  def self.up
    rename_column :causes, :type, :owner_type
  end

  def self.down
    rename_column :causes, :owner_type, :type
  end
end
