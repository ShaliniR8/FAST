class CreateActivityTrackers < ActiveRecord::Migration
  def self.up
    create_table :activity_trackers do |t|
      t.integer  :user_id
      t.datetime :last_active
      t.timestamps
    end
  end

  def self.down
    drop_table :activity_trackers
  end
end
