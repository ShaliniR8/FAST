class CreateRiskControls < ActiveRecord::Migration
  def self.up
    create_table :risk_controls do |t|
      t.string :title
      t.belongs_to :hazard
      t.string :status,:default=>"New"
      t.belongs_to :responsible_user
      t.belongs_to :approver
      t.date :scheduled_completion_date
      t.string :control_type
      t.text :description
      t.text :monitoring
      t.timestamps
    end
  end

  def self.down
    drop_table :risk_controls
  end
end
