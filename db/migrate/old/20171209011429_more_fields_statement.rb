class MoreFieldsStatement < ActiveRecord::Migration
  def self.up
    add_column :query_statements,:user_id,:integer
    add_column :query_statements,:privileges,:text
  end

  def self.down
  end
end
