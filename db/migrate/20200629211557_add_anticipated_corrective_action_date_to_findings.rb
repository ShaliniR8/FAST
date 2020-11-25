class AddAnticipatedCorrectiveActionDateToFindings < ActiveRecord::Migration
  def self.up
    add_column :findings, :anticipated_corrective_action_date, :date
  end

  def self.down
    remove_column :findings, :anticipated_corrective_action_date
  end
end
