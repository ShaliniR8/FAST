class AddIndexToSubmissions < ActiveRecord::Migration
  def self.up
    add_index :submissions, :templates_id
    add_index :submissions, :completed
    add_index :submissions, :user_id
    add_index :submissions, :records_id
  end

  def self.down
    remove_index :submissions, :templates_id
    remove_index :submissions, :completed
    remove_index :submissions, :user_id
    remove_index :submissions, :records_id
  end
end
