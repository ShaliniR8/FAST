class AddThresholdToQuery < ActiveRecord::Migration
  def self.up
    add_column :queries, :threshold, :integer
  end

  def self.down
    remove_column :queries, :threshold
  end
end
