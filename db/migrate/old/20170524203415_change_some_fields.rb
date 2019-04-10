class ChangeSomeFields < ActiveRecord::Migration
  def self.up
    rename_column :investigations,:schedueld_completion_date,:scheduled_completion_date
    add_column :investigations,:local_event_occured,:datetime
    add_column :investigations,:containment,:text
    add_column :investigations,:description,:text
    add_column :investigations,:statement,:text
  end

  def self.down
  end
end
