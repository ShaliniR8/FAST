class RemoveDistributionListsFromQueries < ActiveRecord::Migration
  def self.up
    remove_column :queries, :distribution_lists
  end

  def self.down
    add_column :queries, :distribution_lists, :string
  end
end
