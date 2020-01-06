class CreateDistributionListsTable < ActiveRecord::Migration
  def self.up
    create_table :distribution_lists do |t|
      t.string      :title
      t.string      :description
      t.integer     :created_by_id
      t.timestamps
    end

    create_table :distribution_list_connections do |t|
      t.integer     :user_id
      t.integer     :distribution_list_id
    end
  end

  def self.down
    drop_table :distribution_lists
    drop_table :distribution_list_connections
  end
end
