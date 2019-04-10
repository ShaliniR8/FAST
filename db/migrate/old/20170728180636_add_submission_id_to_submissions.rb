class AddSubmissionIdToSubmissions < ActiveRecord::Migration
  def self.up
    add_column :submissions, :submission_id, :integer
  end

  def self.down
    remove_column :submissions, :submission_id
  end
end
