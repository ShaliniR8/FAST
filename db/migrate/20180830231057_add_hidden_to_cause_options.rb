class AddHiddenToCauseOptions < ActiveRecord::Migration
  def self.up
    add_column :cause_options, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :cause_options, :hidden
  end
end
