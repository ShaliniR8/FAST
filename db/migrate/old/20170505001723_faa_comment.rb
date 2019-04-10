class FaaComment < ActiveRecord::Migration
  def self.up
    add_column :audits,:viewer_note,:text
  end

  def self.down
    remove_column :audits,:viewer_note
  end
end
