class CreateFindings < ActiveRecord::Migration
  def self.up
    create_table :findings do |t|
      t.integer :audit_id
      t.string :title
      t.integer :responsible_user_id
      t.date   :completion_date
      t.text   :reference
      t.string :regulatory_violation
      t.string :policy_vilation
      t.boolean :safety
      t.string  :classification
      t.boolean :repeat
      t.boolean :immediate_action
      t.text    :action_taken
      t.string  :department
      t.integer :approver_id
      t.text    :description
      t.boolean :authority
      t.boolean :controls
      t.boolean :interfaces
      t.boolean :policy
      t.boolean :procedures
      t.boolean :process_measures
      t.boolean :responsibility
      t.string  :other
      t.string  :severity
      t.string  :likelihood
      t.string  :risk_factor
      t.timestamps
    end
  end

  def self.down
    drop_table :findings
  end
end
