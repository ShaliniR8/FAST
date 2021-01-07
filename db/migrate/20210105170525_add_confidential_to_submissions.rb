class AddConfidentialToSubmissions < ActiveRecord::Migration
  def self.up
    add_column :submissions, :confidential, :boolean, default: false
  end

  def self.down
    remove_column :submissions, :confidential
  end
end
