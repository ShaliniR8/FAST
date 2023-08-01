class ChangeStringToTextForFields < ActiveRecord::Migration
  def self.up
    change_column :attachments, :caption, :text
    change_column :checklist_headers, :description, :text
    change_column :custom_options, :description, :text
    change_column :distribution_lists, :description, :text
    change_column :extension_requests, :address_comment, :text
    change_column :newsletter_attachments, :caption, :text
    change_column :participations, :comment, :text
    change_column :query_conditions, :value, :text
    change_column :reports, :description, :text
  end

  def self.down
    change_column :attachments, :caption, :string
    change_column :checklist_headers, :description, :string
    change_column :custom_options, :description, :string
    change_column :distribution_lists, :description, :string
    change_column :extension_requests, :address_comment, :string
    change_column :newsletter_attachments, :caption, :string
    change_column :participations, :comment, :string
    change_column :query_conditions, :value, :string
    change_column :reports, :description, :string
  end
end
