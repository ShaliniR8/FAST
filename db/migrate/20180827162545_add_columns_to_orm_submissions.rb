class AddColumnsToOrmSubmissions < ActiveRecord::Migration
  def self.up
    add_column :orm_submissions, :extra_low, :integer, :default => 0
    add_column :orm_submissions, :extra_moderate, :integer, :default => 0
    add_column :orm_submissions, :extra_high, :integer, :default => 0
  end

  def self.down
    remove_column :orm_submissions, :extra_low
    remove_column :orm_submissions, :extra_moderate
    remove_column :orm_submissions, :extra_high
  end
end
