class AddStatusSubmission < ActiveRecord::Migration
  def self.up
    add_column :submissions ,:completed,:boolean
  end

  def self.down
  end
end
