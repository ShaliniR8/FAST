class AddDefaultStatusAndCustomNotificationsToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :default_status, :string
    add_column :templates, :submitter_message, :text
    add_column :templates, :notifier_message, :text
    if !CustomOption.where(title: 'Event Titles').present?
      CustomOption.create(title: 'Event Titles', description: 'This manages all the Event Titles in the System')
    end
  end

  def self.down
    remove_column :templates, :notifier_message
    remove_column :templates, :submitter_message
    remove_column :templates, :default_status
    event_titles = CustomOption.where(title: 'Event Titles')
    if event_titles.present?
      event_titles.each(&:destroy)
    end
  end
end
