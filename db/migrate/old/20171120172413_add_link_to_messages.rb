class AddLinkToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :link_type, :string
    add_column :messages, :link_id, :integer
  end

  def self.down
    remove_column :messages, :link_type
    remove_column :messages, :link_id
  end
end
