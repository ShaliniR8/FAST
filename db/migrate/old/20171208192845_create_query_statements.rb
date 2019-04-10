class CreateQueryStatements < ActiveRecord::Migration
  def self.up
    create_table :query_statements do |t|
      t.string :title
      t.boolean :visualize
      t.timestamps
    end
  end

  def self.down
    drop_table :query_statements
  end
end
