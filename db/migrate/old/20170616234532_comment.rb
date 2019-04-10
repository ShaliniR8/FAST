class Comment < ActiveRecord::Migration
  def self.up
    add_column :evaluations,:comment,:text
  end

  def self.down
  end
end
