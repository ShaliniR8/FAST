class AddDistributionListsToQuery < ActiveRecord::Migration
  def self.up
    add_column :queries, :distribution_lists, :string
  end

  def self.down
    remove_column :queries, :distribution_lists
  end
end
