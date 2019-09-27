class MakesMessagePolymorphic < ActiveRecord::Migration
  def self.up
    add_column :messages, :owner_type, :string
    add_column :messages, :owner_id, :integer

    Message.update_all("owner_type = link_type")
    Message.update_all("owner_id = link_id")
    Message.where(owner_type: 'Report').update_all('owner_type = "Record"')
    Message.where(owner_type: 'Event').update_all('owner_type = "Report"')
    Message.where(link_type: '').update_all('owner_type = NULL')
    Message.where(link_type: '').update_all('owner_id = NULL')

    remove_column :messages, :link
    remove_column :messages, :link_type
    remove_column :messages, :link_id
  end

  def self.down
    add_column :messages, :link, :string
    add_column :messages, :link_type, :string
    add_column :messages, :link_id, :integer

    Message.update_all("link_type = owner_type")
    Message.update_all("link_id = owner_id")
    Message.transaction do
      Message.all.each do |message|
        if message.link_id.present?
          message.link = "#{message.link_type.underscore.pluralize}/#{message.link_id}"
          message.save
        end
      end
    end
    Message.where(link_type: 'Report').update_all('link_type = "Event"')
    Message.where(link_type: 'Record').update_all('link_type = "Report"')

    remove_column :messages, :owner_type
    remove_column :messages, :owner_id
  end
end
