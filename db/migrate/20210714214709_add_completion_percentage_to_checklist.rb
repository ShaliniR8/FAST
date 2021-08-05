class AddCompletionPercentageToChecklist < ActiveRecord::Migration
  def self.up
    add_column :checklists, :completion_percentage, :decimal, :precision => 10, :scale => 4, :default => 0.0
  end

  def self.down
    remove_column :checklists, :completion_percentage
  end
end
