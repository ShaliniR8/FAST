class AddStatusAndCommentsToTask < ActiveRecord::Migration
  def self.up
    add_column :sms_tasks, :status,        :string, default: "New"
    add_column :sms_tasks, :res_comment,   :text
    add_column :sms_tasks, :final_comment, :text
    add_column :sms_tasks, :close_date,    :datetime
  end

  def self.down
    remove_column :sms_tasks, :status
    remove_column :sms_tasks, :res_comment
    remove_column :sms_tasks, :final_comment
    remove_column :sms_tasks, :close_date
  end
end
