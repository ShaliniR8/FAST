class RenameExp < ActiveRecord::Migration
  def self.up
    rename_column :expectations,:framework_id,:owner_id
  end

  def self.down
  end
end
