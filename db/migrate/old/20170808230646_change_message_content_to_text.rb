class ChangeMessageContentToText < ActiveRecord::Migration
  def self.up
  	change_column :messages, :content, :text
    add_column :messages, :response_outbox_id, :integer
  	add_column :messages, :outbox_id, :integer
  	add_column :message_accesses, :message_outbox_id, :integer
  	add_column :message_accesses, :user_poc_id, :integer
  end

  def self.down
  	change_column :messages, :content, :string
  	remove_column :messages, :outbox_id
  	remove_column :message_accesses, :message_outbox_id
  	remove_column :message_accesses, :user_poc_id
    remove_column :messages, :reply_outbox_id

  end
end
