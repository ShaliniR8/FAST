class CreateInvestigations < ActiveRecord::Migration
  def self.up
    create_table :investigations do |t|
      t.string :title 
      t.belongs_to :investigator
      t.date :schedueld_completion_date
      t.date :open_date
      t.date :complete_date
      t.date :investigation_type
      t.boolean :ntsb
      t.boolean :safety_hazard
      t.string :source
      t.datetime :event_occured
      t.belongs_to :final_approver 
      t.text :approver_comment
      t.text :notes
      t.string :likelihood
      t.string :severity
      t.string :risk_factor
      t.timestamps
    end
  end

  def self.down
    drop_table :investigations
  end
end
