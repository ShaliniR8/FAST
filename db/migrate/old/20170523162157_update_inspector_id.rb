class UpdateInspectorId < ActiveRecord::Migration
  def self.up
    rename_column :inspections,:auditor_id,:inspector_id
  end

  def self.down
  end
end
