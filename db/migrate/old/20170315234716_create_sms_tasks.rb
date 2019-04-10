class CreateSmsTasks < ActiveRecord::Migration
  def self.up
    create_table :sms_tasks do |t|
      t.belongs_to :im
      t.string :title
      t.string :department
      t.integer :res
      t.date    :completion
      t.integer :app_id
      t.string  :action
      t.text    :description
      t.timestamps
    end
  end

  def self.down
    drop_table :sms_tasks
  end
end
