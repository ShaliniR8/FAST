class AddDefaultStatusAndCustomNotificationsToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :default_status, :string
    add_column :templates, :submitter_message, :text
    add_column :templates, :notifier_message, :text
  end

  def self.down
    remove_column :templates, :notifier_message
    remove_column :templates, :submitter_message
    remove_column :templates, :default_status
  end
end
