class RenameSubmissionObjectId < ActiveRecord::Migration
  def self.up
    rename_column :submissions, :object_id, :user_object_id
  end

  def self.down
    rename_column :submissions, :user_object_id, :object_id
  end
end
