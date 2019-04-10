class AddTimestampToNotices < ActiveRecord::Migration
  def self.up
    change_table :notices do |t|
      t.timestamps
    end
  end

  def self.down
  end
end
