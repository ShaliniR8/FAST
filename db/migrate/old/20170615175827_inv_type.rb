class InvType < ActiveRecord::Migration
  def self.up
    rename_column :investigations,:investigation_type,:inv_type
  end

  def self.down
  end
end
