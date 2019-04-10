class AddColumnsToSubmissions < ActiveRecord::Migration
  def self.up
  	add_column :submissions, :owner_id, :integer
  	add_column :submissions, :type, :string
  end

  def self.down
  end
end
