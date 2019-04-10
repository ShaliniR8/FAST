class AddVersionAndTrackingIdentifierToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :version, :integer
    add_column :documents, :tracking_identifier, :string
  end

  def self.down
    remove_column :documents, :version
    remove_column :documents, :tracking_identifier
  end
end
