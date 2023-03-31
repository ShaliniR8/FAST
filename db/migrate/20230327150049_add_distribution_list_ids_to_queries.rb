class AddDistributionListIdsToQueries < ActiveRecord::Migration
  def self.up
    add_column :queries, :distribution_list_ids, :string
  end

  def self.down
    remove_column :queries, :distribution_list_ids
  end
end
