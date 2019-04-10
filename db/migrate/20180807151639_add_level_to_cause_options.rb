class AddLevelToCauseOptions < ActiveRecord::Migration
  def self.up
    add_column :cause_options, :level, :integer
  end

  def self.down
    remove_column :cause_options, :level
  end
end
