class AddMeetingObjIdToPackages < ActiveRecord::Migration
  def self.up
    add_column :packages, :meeting_obj_id, :integer
  end

  def self.down
    remove_column :packages, :meeting_obj_id
  end
end
