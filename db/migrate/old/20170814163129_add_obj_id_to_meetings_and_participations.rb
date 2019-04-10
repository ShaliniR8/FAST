class AddObjIdToMeetingsAndParticipations < ActiveRecord::Migration
  def self.up
  	add_column :meetings, :obj_id, :integer
  	add_column :participations, :obj_id, :integer
  	add_column :participations, :poc_id, :integer
  end

  def self.down
  	remove_column :meetings, :obj_id
  	remove_column :participations, :obj_id
  	remove_column :participations, :poc_id
  end
end
