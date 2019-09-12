class RemoveResponsibleUserAndNotificationTables < ActiveRecord::Migration
  def self.up
    drop_table :responsible_users
    drop_table :notifications
  end

  def self.down
    create_table "responsible_users", :force => true do |t|
      t.integer   :owner_id
      t.string    :type
      t.integer   :user_id
      t.string    :status
      t.text      :comments
      t.text      :instructions
      t.timestamps
    end
    create_table "notifications", :force => true do |t|
      t.timestamps
      t.string        :type
      t.integer       :owner_id
      t.string        :users_id
      t.string        :message
      t.date          :notify_date
    end
  end
end
