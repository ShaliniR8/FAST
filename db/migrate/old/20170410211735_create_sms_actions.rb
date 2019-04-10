class CreateSmsActions < ActiveRecord::Migration
  def self.up
    create_table :sms_actions do |t|
      t.string :title
      t.string :responsible_department
      t.date   :schedule_completion_date
      t.boolean :immediate_action
      t.string  :immediate_action_comment
      t.boolean :comprehensive_action
      t.string  :comprehensive_action_comment
      t.belongs_to :approver
      t.string  :action_taken
      t.text    :description
      t.belongs_to :finding
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :sms_actions
  end
end
