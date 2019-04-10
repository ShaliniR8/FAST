class FindinIdRename < ActiveRecord::Migration
  def self.up
    rename_column :sms_actions,:finding_id,:owner_id
  end

  def self.down
  end
end
