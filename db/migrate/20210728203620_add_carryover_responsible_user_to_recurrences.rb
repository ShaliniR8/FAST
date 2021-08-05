class AddCarryoverResponsibleUserToRecurrences < ActiveRecord::Migration
  def self.up
    add_column :recurrences, :carryover_responsible_user, :boolean, :default => false
  end

  def self.down
    remove_column :recurrences, :carryover_responsible_user
  end
end
