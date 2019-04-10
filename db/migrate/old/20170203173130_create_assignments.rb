class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.belongs_to :access_controls
      t.belongs_to :privileges
      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
